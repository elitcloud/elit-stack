variable profile {
  default = "terraform"
}

variable region {
  default = "us-west-2"
}

variable name {
  default     = "elit"
  description = "the name of your stack, e.g. \"elit\""
}

variable "cidr" {
  description = "the CIDR block to provision for the VPC, if set to something other than the default, both internal_subnets and external_subnets have to be defined as well"
  default     = "10.0.0.0/16"
}

variable environment {
  default     = "staging"
  description = "the name of your environment, e.g. \"production\""
}

variable "key_name" {
  default     = "elit"
  description = "the name of the ssh key to use, e.g. \"internal-key\""
}

variable "bastion_instance_type" {
  description = "Instance type for the bastion"
  default     = "t2.micro"
}

variable "domain_name" {
  description = "the internal DNS name to use with services"
  default     = "elit.cloud"
}

variable "domain_name_servers" {
  description = "the internal DNS servers, defaults to the internal route53 server of the VPC"
  default     = ""
}
