locals {
  cluster = var.account.env
  region = var.account.region
  az = var.account.az

  budget_limit = var.budget.limit
  budget_threshold_percentage = 50
  budget_services = {
    EC2 = {
      budget_limit = "16.0"
    },
    ECR = {
      budget_limit = "2.0"
    },
    S3 = {
      budget_limit = "2.0"
    }
  }
}

#module network {
#  source = "./network"
#
#  cluster = local.cluster
#  az = local.az
#}
#
#module vms {
#  source = "./vms"
#
#  cluster = local.cluster
#  region = local.region
#  env = local.cluster
#  vpc_id = module.network.vpc_id
#  subnet_id = module.network.subnet_ids.private_0
#}

module budgets {
  source = "./budgets"

  env = local.cluster
  account_name = local.cluster
  budget_limit = local.budget_limit
  budget_threshold_percentage = local.budget_threshold_percentage
  budget_services = local.budget_services
}
