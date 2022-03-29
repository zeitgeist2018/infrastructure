#!/bin/bash

mkdir -p /var/log/provision
exec >/var/log/provision/provision.log 2>/var/log/provision/provision-error.log

SLACK_CHANNEL="#infrastructure-events"
PRIVATE_IP=$(ifconfig eth0 | grep -w inet | awk '{print $2}')

function notify() {
    echo $1
    if [ $2 == "success" ]; then
        EMOJI=':green_heart:'
    elif [ $2 == "warning" ]; then
        EMOJI=':warning:'
    elif [ $2 == "error" ]; then
        EMOJI=':red_circle:'
    fi

    sendSlackMessage "${EMOJI} $1" $2
}

function sendSlackMessage() {
  read -r -d '' JSON << EOF
      {
        "channel": "$SLACK_CHANNEL",
        "attachments": [
          {
              "title": "Node: $PRIVATE_IP",
              "color": "$2",
              "text": "$1"
          }
        ]
      }
EOF

  curl -X POST -H 'Content-type: application/json' $SLACK_WEBHOOK_URL --data "${JSON}"
}

notify "Starting provisioning of node." "success" || true

cd /home/ec2-user/ansible
sudo amazon-linux-extras install ansible2 -y

notify "Applying ansible playbook" "success" || true

cat > inventory << EOF
[localhost]
127.0.0.1 ansible_connection=local
EOF
ansible-playbook --inventory inventory main.yml --diff

if [ $? -ne 0 ]
then
    notify "Provisioning for ${ENV} ansible failed." "error"
    exit 1
else
    notify "Provisioning for ${ENV} ok." "success" || true
fi
