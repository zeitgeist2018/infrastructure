#!/bin/bash

SLACK_WEBHOOK_URL=$1

function sendNotifications() {
  sendSlackNotification "$@" || true
  sendOpsgenieNotification "$@" || true
}

function slackMessage() {
    if [ $2 == "success" ]; then
        EMOJI=':green_heart:'
    elif [ $2 == "warning" ]; then
        EMOJI=':warning:'
    elif [ $2 == "error" ]; then
        EMOJI=':red_circle:'
    fi

    read -r -d '' JSON << EOF
    {
      "channel": "#infrastructure-events",
      "attachments": [
        {
            "title": "$(hostname)",
            "color": "$2",
            "text": "${EMOJI} $1"
        }
      ]
    }
EOF

    curl -X POST -H 'Content-type: application/json' $SLACK_WEBHOOK_URL --data "${JSON}"
}
INSTANCE_FILE=/root/provision/instance.json
env=$(cat $INSTANCE_FILE | jq -r '.[] | .[] | select(.Key=="ENV") | .Value')

if [[ -z ${env} ]]; then
    slackMessage "Self-provisioning failed: could not determine tags." "danger"
#    shutdown
    exit 1
fi

cd /root/provision
cat > inventory << EOF
[localhost]
127.0.0.1 ansible_connection=local
EOF
ansible-playbook --inventory inventory main.yml --diff

if [ $? -ne 0 ]
then
    slackMessage "Provisioning for ${env} ansible failed." "error"
#    shutdown
    exit 1
else
    slackMessage "Provisioning for ${env} ok." "success" || true
fi
