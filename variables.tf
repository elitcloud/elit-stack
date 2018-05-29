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
