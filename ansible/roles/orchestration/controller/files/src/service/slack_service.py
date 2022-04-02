import os

from slack import WebClient


class SlackService:
    def __init__(self, channel='#infrastructure-events'):
        self.slack_token = os.environ.get('SLACK_TOKEN')
        self.channel = channel
        self.client = WebClient(token=self.slack_token)

    def send_message(self, content):
        self.client.chat_postMessage(
            channel=self.channel,
            message=content
        )
        return True
