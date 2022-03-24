module billing_alarm {
  source = "../../modules/budget"

  account = var.account
  account_budget_limit = var.budget_limit
  threshold_percentage = var.budget_threshold_percentage
  services = var.budget_services
}
