variable name {}

variable environment {}

variable vpc_id {}

variable ssh_cidr {
  description = "Specific cidr for external cidr. Default for world."
  default     = "0.0.0.0/0"
}
