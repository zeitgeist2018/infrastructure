import json
import os
import requests
from service.slack_service import SlackService as Slack
from service.logging_service import LoggingService
from service.node_service import NodeService

log = LoggingService()

log.info("Starting node discovery")
_node_service = NodeService()
_slack = Slack()

# No nodes = Init cluster (BOOTSTRAP). Bootstrap node stays in bootstrap (single-manager mode) until another node auto joins
# 1 node in BOOTSTRAP = Join it. Both turn CLUSTER mode
# 1 node in BOOTSTRAP | 1 node in = Wait until both are in cluster mode?
# 2 nodes in cluster = join any of them
_node_service.update_node()
