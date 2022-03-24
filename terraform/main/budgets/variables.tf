variable account {
  type = map(string)
}

variable tags {
  type = map(string)
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
