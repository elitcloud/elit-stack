variable name {}
variable environment {}
variable region {}

variable "memory" {
  description = "The number of MiB of memory to reserve for the container"
  default     = 2048
}

variable "cpu" {
  description = "The number of cpu units to reserve for the container"
  default     = 1024
}

variable "log_group" {
  description = "log group"
}

variable "ecs_execution_role_arn" {
  description = "ecs_execution_role_arn"
}

variable "ecs_autoscale_role_arn" {
  description = "ecs_autoscale_role_arn"
}

variable "vpc_id" {
  description = "vpc_id"
}

variable "public_subnets" {
  description = "public_subnets"
  type        = "list"
}

variable "security_groups" {
  description = "security_groups"
  type        = "list"
}
