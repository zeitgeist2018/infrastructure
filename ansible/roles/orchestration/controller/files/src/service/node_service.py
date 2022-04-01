import os
import time
from enum import Enum

import boto3
import docker

from .logging_service import LoggingService

log = LoggingService()


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
    def __init__(self):
        self.docker_client = docker.from_env()
        env = os.getenv("ENV")
        region = os.getenv("REGION")
        dynamodb = boto3.resource('dynamodb', region_name=region)
        self.db = dynamodb.Table(f'{env}-cluster_control')
        self.node_ip = os.popen('hostname --all-ip-addresses | awk \'{print $2}\'').read().strip()

    def get_registered_nodes(self):
        return list(map(lambda node: {
            'IP': node['IP'],
            'STATUS': NodeStatus.value_of(node['STATUS']),
            'TYPE': NodeType.value_of(node['TYPE']),
            'MANAGER_TOKEN': node.get('MANAGER_TOKEN'),
            'WORKER_TOKEN': node.get('WORKER_TOKEN')
        }, self.db.scan().get('Items', [])))

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

    def register_node(self, type: NodeType, status: NodeStatus, error: str = None):
        item = {
            'IP': self.node_ip,
            'TYPE': type.name,
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
            all_registered_nodes = self.get_registered_nodes()
            registered_nodes = list(filter(lambda node: node['IP'] != self.node_ip, all_registered_nodes))
            bootstrap_node = self.find(lambda node: node['STATUS'] == NodeStatus.BOOTSTRAP, registered_nodes)
            cluster_manager_nodes = list(filter(
                lambda node: node['STATUS'] == NodeStatus.CLUSTER and node['TYPE'] == NodeType.MANAGER,
                registered_nodes
            ))

            swarm_active = len(self.docker_client.swarm.attrs) > 0

            if bootstrap_node is not None:
                log.info(f'Bootstrap node found on {bootstrap_node["IP"]}')
                if swarm_active:
                    log.warn('Leaving current cluster')
                    self.docker_client.swarm.leave(True)
                log.info('Joining bootstrap node')
                self.join_cluster(bootstrap_node['IP'], self.extract_token(bootstrap_node))
                self.register_node(self.get_node_type(), NodeStatus.CLUSTER)
            elif len(cluster_manager_nodes) > 0:
                print('Joining existing cluster')
                self.join_cluster(cluster_manager_nodes['IP'], self.extract_token(cluster_manager_nodes))
                self.register_node(self.get_node_type(), NodeStatus.CLUSTER)
            else:
                print('Registering as bootstrap node')
                self.register_node(self.get_node_type(), NodeStatus.BOOTSTRAP)
        except Exception as e:
            log.err(e)
            self.register_node(self.get_node_type(), NodeStatus.ERROR, str(e))
