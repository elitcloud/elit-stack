variable name {}

variable environment {}

variable vpc_id {}

variable vpc_cidr {
  default = "10.0.0.0/16"
}

variable bastion_cidr {
  default = "0.0.0.0/0"
}