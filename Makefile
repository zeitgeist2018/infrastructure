.ONESHELL:

ENV=dev
STATE_PATH?=state/terraform.tfstate
STATE_BUCKET?=terraform---state
STATE_PARAMS=-backend-config='bucket=$(STATE_BUCKET)' -backend-config='key=$(STATE_PATH)'

NODE?=0
NODE_IP := $(shell cat "./terraform/output/${ENV}-${NODE}-config.json" | jq -r '.public_ip')
NODE_KEY := "./terraform/output/${ENV}-${NODE}-private-key.pem"

init: clean
	cd terraform && \
	tfenv install && \
	terraform init -reconfigure $(STATE_PARAMS) -upgrade && \
	terraform get

plan: init
	cd terraform && \
	terraform plan -out terraform.plan -var-file 'tfvars/${ENV}.tfvars'

apply:
	cd terraform && \
	terraform apply -auto-approve -parallelism=5 terraform.plan

destroy:
	cd terraform && \
	terraform destroy -auto-approve -var-file 'tfvars/${ENV}.tfvars' && \
	echo '{"version": 1}' | aws s3 cp - s3://$(STATE_BUCKET)/$(STATE_PATH)

clean:
	cd terraform && \
	rm -fR terraform.* && \
	rm -fR .terraform/modules

ssh-node:
	ssh -i ${NODE_KEY} -o StrictHostKeychecking=no -o IdentitiesOnly=yes "ec2-user@${NODE_IP}"
