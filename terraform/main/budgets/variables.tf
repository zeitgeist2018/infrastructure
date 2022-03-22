variable env {
  type = string
}

variable account_name {
  type = string
}

variable budget_limit {
  type = string
}

variable budget_threshold_percentage {
  type = number
}

variable budget_services {
  type = map(object({
    budget_limit = string
  }))
}
