#!/bin/bash

function notify() {
    echo $1
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

notify "Starting provisioning of node." "success" || true


INSTANCE_FILE=/home/ec2-user/instance.json
aws --region ${REGION} ec2 describe-tags --filter Name=resource-id,Values=$(curl -s http://169.254.169.254/latest/meta-data/instance-id) > $INSTANCE_FILE
ENV=$(cat $INSTANCE_FILE | jq -r '.[] | .[] | select(.Key=="ENV") | .Value')
echo "ENV=\"$ENV\"" >> /etc/environment

if [[ -z ${ENV} ]]; then
    notify "Self-provisioning failed: could not determine tags." "danger"
    exit 1
fi

cd /home/ec2-user/ansible
pip install awscli ansible==4.9.0

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
