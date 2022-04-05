account = {
  id = "your-account-id"
  region = "us-east-1"
  az = "us-east-1a"
  env = "your-env-name"
}

budget = {
  limit                = 15
  threshold_percentage = 50
}
budget_services = {
  EC2 = {
    budget_limit = "12.0"
  },
  ECR = {
    budget_limit = "1.0"
  },
  S3 = {
    budget_limit = "2.0"
  }
}

slack_webhook_url = "your-slack-hook-url"
slack_token = "your-slack-bot-token"
