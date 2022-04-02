import boto3
import docker
import os
import time
from enum import Enum

from .logging_service import LoggingService
from .slack_service import SlackService

class NodeStatus(Enum):
    BOOTSTRAP = 1
    CLUSTER = 2
    ERROR = 3

    @classmethod
    def value_of(cls, value):
        for k, v in cls.__members__.items():
            if k == value:
                return v
        else:
            raise ValueError(f"'{cls.__name__}' enum not found for '{value}'")


class NodeType(Enum):
    MANAGER = 1
    WORKER = 2

    @classmethod
    def value_of(cls, value):
        for k, v in cls.__members__.items():
            if k == value:
                return v
        else:
            raise ValueError(f"'{cls.__name__}' enum not found for '{value}'")


class NodeService:
    def __init__(self, slack_service: SlackService, log_service: LoggingService):
        self.slack_service = slack_service
        self.log = log_service
        self.docker_client = docker.from_env()
        env = os.getenv("ENV")
        # env = 'dev'
        region = os.getenv("REGION")
        # region = 'us-east-1'
        dynamodb = boto3.resource('dynamodb', region_name=region)
        self.db = dynamodb.Table(f'{env}-cluster_control')
        self.node_ip = os.popen('hostname --all-ip-addresses | awk \'{print $2}\'').read().strip()
        # self.node_ip = '192.168.100.128'

    def get_previous_node_status(self):
        entry = self.db.query(
            KeyConditionExpression=Key('IP').eq(self.node_ip)
        ).get('Items', [])
        if entry is not None:
            return NodeStatus.value_of(entry['Items'][0]['STATUS'])

    def get_registered_nodes(self, skip_self: bool = True):
        nodes = list(map(lambda node: {
            'IP': node['IP'],
            'STATUS': NodeStatus.value_of(node['STATUS']),
            'TYPE': NodeType.value_of(node['TYPE']),
            'MANAGER_TOKEN': node.get('MANAGER_TOKEN'),
            'WORKER_TOKEN': node.get('WORKER_TOKEN')
        }, self.db.scan().get('Items', [])))
        if skip_self:
            return list(filter(lambda node: node['IP'] != self.node_ip, nodes))
        else:
            return nodes

    def get_manager_token(self):
        return self.docker_client.swarm.attrs["JoinTokens"]["Manager"]

    def get_worker_token(self):
        return self.docker_client.swarm.attrs["JoinTokens"]["Worker"]

    @staticmethod
    def current_time_millis():
        return round(time.time() * 1000)

    @staticmethod
    def find(f, seq):
        for item in seq:
            if f(item):
                return item

    def register_node(self, status: NodeStatus, error: str = None):
        item = {
            'IP': self.node_ip,
            'TYPE': self.get_node_type().name,
            'STATUS': status.name,
            'UPDATED_ON': self.current_time_millis()
        }
        if type == NodeType.MANAGER and status != NodeStatus.ERROR:
            item['MANAGER_TOKEN'] = self.get_manager_token()
            item['WORKER_TOKEN'] = self.get_worker_token()
        if error:
            item['ERROR'] = error
        self.db.put_item(Item=item)

    def get_node_type(self):
        return NodeType.value_of(os.getenv('NODE_TYPE', NodeType.MANAGER.name).upper())

    def is_manager(self, node_type: NodeType):
        return node_type == NodeType.MANAGER

    def extract_token(self, node):
        if self.is_manager(self.get_node_type()):
            return node['MANAGER_TOKEN']
        else:
            return node['WORKER_TOKEN']

    def join_cluster(self, ip, token):
        self.docker_client.swarm.join(
            remote_addrs=[ip],
            join_token=token,
            advertise_addr=self.node_ip
        )

    def update_node(self):
        try:
            registered_nodes = self.get_registered_nodes()
            other_manager_nodes = list(filter(lambda node:
                                              (node['STATUS'] == NodeStatus.BOOTSTRAP or
                                               node['STATUS'] == NodeStatus.CLUSTER)
                                              and node['TYPE'] == NodeType.MANAGER,
                                              registered_nodes
                                              ))
            try:
                connected_to_cluster = len(self.docker_client.nodes.list()) > 1
            except Exception as e:
                connected_to_cluster = False
            if self.get_node_type() == NodeType.MANAGER:    # Manager flow
                if connected_to_cluster:
                    self.log.debug("Already connected to cluster, nothing to do")
                    self.register_node(NodeStatus.CLUSTER)
                else:
                    was_bootstrap = self.get_previous_node_status() == NodeStatus.BOOTSTRAP
                    if was_bootstrap:
                        self.log.info("Waiting for other nodes")
                        self.register_node(NodeStatus.BOOTSTRAP)
                    else:
                        if len(other_manager_nodes) > 0:
                            manager = other_manager_nodes[0]
                            ip = manager['IP']
                            self.log.info(f'Found another manager, connecting to it on {ip}')
                            self.slack_service.send_message(
                                f'{self.node_ip}: Found another manager, connecting to it on {ip}'
                            )
                            self.join_cluster(ip, self.extract_token(manager))
                            self.register_node(NodeStatus.CLUSTER)
                        else:
                            self.log.info('Registering as bootstrap')
                            self.slack_service.send_message(
                                f'{self.node_ip}: Registering as bootstrap'
                            )
                            self.register_node(NodeStatus.BOOTSTRAP)
            else:    # Worker flow
                if connected_to_cluster:
                    self.log.debug("Already connected to cluster, nothing to do")
                    self.register_node(NodeStatus.CLUSTER)
                else:
                    if len(other_manager_nodes) > 0:
                        manager = other_manager_nodes[0]
                        ip = manager['IP']
                        self.log.info(f'Worker found a manager, connecting to it on {ip}')
                        self.slack_service.send_message(
                            f'{self.node_ip}: Worker found a manager, connecting to it on {ip}'
                        )
                        self.join_cluster(ip, self.extract_token(manager))
                        self.register_node(NodeStatus.CLUSTER)
                    else:
                        self.log.info('No managers found yet, waiting...')
                        self.slack_service.send_message(
                            f'{self.node_ip}: Worker hasn\'t found any managers yet. Waiting...'
                        )
        except Exception as e:
            self.log.err(e)
            self.register_node(NodeStatus.ERROR, str(e))
