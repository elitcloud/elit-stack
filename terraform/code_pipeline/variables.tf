variable "name" {}
variable environment {}

variable "region" {
  description = "The region to use"
}

variable "repository_url" {
  description = "The url of the ECR repository"
}

variable "ecs_cluster_name" {
  description = "The cluster that we will deploy"
}

variable "ecs_service_name" {
  description = "The ECS service that will be deployed"
}

variable "github_owner" {}

variable "github_repo" {}

variable "github_branch" {}

variable "github_token" {}

variable "run_task_subnet_id" {
  description = "The subnet Id where single run task will be executed"
}

variable "security_groups" {
  type        = "list"
  description = "The security group Ids attached where the single run task will be executed"
}
