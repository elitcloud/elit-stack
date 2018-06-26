variable profile {
  default = "terraform"
}

variable name {
  default     = "elit"
  description = "the name of your stack, e.g. \"elit\""
}

variable environment {
  default     = "production"
  description = "the name of your environment, e.g. \"production\""
}

variable region {
  default     = "us-west-2"
  description = "the region of your stack, e.g. \"us-west-2\""
}

variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "the cidr block of your vpc"
}
