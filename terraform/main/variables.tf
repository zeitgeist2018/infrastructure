variable account {
  type = map(string)
}

variable budget {
  type = map(string)
}
variable budget_services {
  type = map(object({
    budget_limit = string
  }))
}

variable slack_webhook_url {
  type = string
}
