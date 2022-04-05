# Description
Infrastructure with all the components needed for a modern microservice environment.
This is not production ready, but you can deploy it to a home server and use it for learning purposes.

# Prerequisites
* Create an IAM user with cli credentials so terraform can use it to generate the cluster.
  This user should have enough permissions to create all necessary infrastructure, like launching EC2 instances,
  creating DynamoDB tables, networks, etc.
* Create a S3 bucket for terraform state, and put its name in the Makefile, in the variable `STATE_BUCKET`.
* Create a Slack app, and generate a token for it. Also, enable incoming webhooks. Then, create a channel
  called `infrastructure-events`. The nodes of the cluster will notify you about their status changes via Slack.
* Create tfvars files for every environment you want to create. You can use `tfvars/template.tfvars` as a template.

# Components
## Ready
* Docker swarm cluster

## Not ready yet
* Reverse proxy
* CI/CD platform
* Artifact repository
* Monitoring platform

# Run it
Once you've prepared all prerequisites:
1. Get your terraform IAM credentials, and export them in the terminal:
    ```
    export AWS_ACCESS_KEY=your-access-key
    export AWS_SECRET_ACCESS_KEY=your-secret-access-key
    ```
2. Run `make plan`, and if the plan convinces you, run `make apply`
3. After creating all the infrastructure, you should see the nodes
already talking to you via Slack
