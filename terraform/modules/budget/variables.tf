variable account {
  type = map(string)
}

variable account_budget_limit {
  type = string
}

variable threshold_percentage {
  type = number
}

variable services {
  description = "List of AWS services to be monitored in terms of costs"

  type = map(object({
    budget_limit = string
  }))
}
