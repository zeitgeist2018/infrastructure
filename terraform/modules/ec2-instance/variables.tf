variable account {
  type = map(string)
}

variable tags {
  type = map(string)
}

variable subnet_id {
  type = string
}

variable sg_id {
  type = string
}

variable elastic_ip {
  type = bool
}

variable private_ip {
  type = string
}

variable vpc_id {
  type = string
}

variable instance_name_suffix {
  type = string
}

variable ami {
  type = string
}

variable instance_type {
  type = string
}

variable disk {
  type = number
  default = 30
}

variable associate_public_ip_address {
  type = bool
}

variable cloud_init_file {
  type = string
}
