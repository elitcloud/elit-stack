variable "name" {
  description = "Zone name, e.g stack.local"
}

variable "vpc_id" {
  description = "The VPC ID (omit to create a public zone)"
  default     = ""
}

variable "domain" {}

variable "lb_dns_name" {}

variable "lb_zone_id" {}
