variable env {
  type = string
}

variable cluster {
  type = string
}

variable region {
  type = string
}

variable vpc_id {
  type = string
}

variable subnet_id {
  type = string
}

locals {
  tags = {
    "Cluster" = var.cluster
  }
}