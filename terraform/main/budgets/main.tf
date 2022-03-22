module billing_alarm {
  source = "../../modules/budget"

  env = var.env
  account_name = "${var.account_name}-${var.env}"
  account_budget_limit = var.budget_limit
  threshold_percentage = var.budget_threshold_percentage
  services = var.budget_services
}
