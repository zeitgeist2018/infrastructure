import os
import ssl
import certifi
from slack import WebClient


class SlackService:
    def __init__(self, channel='#infrastructure-events'):
        self.slack_token = os.environ.get('SLACK_TOKEN')
        self.channel = channel
        ssl_context = ssl.create_default_context(cafile=certifi.where())
        self.client = WebClient(token=self.slack_token, ssl=ssl_context)

    def send_message(self, content):
        self.client.chat_postMessage(
            channel=self.channel,
            text=content,
        )
        return True
