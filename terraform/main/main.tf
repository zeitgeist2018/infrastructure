locals {
  common_tags = {
    ENV = var.account.env
  }
}

module network {
  source = "./network"

  account = var.account
  tags    = local.common_tags
  az      = var.account.az
}

module vms {
  source = "./vms"

  account   = var.account
  tags      = local.common_tags
  vpc_id    = module.network.vpc_id
  subnet_id = module.network.subnet_ids.private_0
  slack_webhook_url = var.slack_webhook_url
}

module budgets {
  source = "./budgets"

  account                     = var.account
  tags                        = local.common_tags
  budget_limit                = var.budget.limit
  budget_threshold_percentage = var.budget.threshold_percentage
  budget_services             = var.budget_services
}
