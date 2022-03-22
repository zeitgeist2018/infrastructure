variable env {
  type = string
}

variable account_name {
  type = string
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
