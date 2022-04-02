from service.slack_service import SlackService as Slack
from service.logging_service import LoggingService
from service.node_service import NodeService

_node_service = NodeService(Slack(), LoggingService())

_node_service.update_node()
