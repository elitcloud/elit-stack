# https://www.terraform.io/docs/backends/config.html
# terraform {
#   backend "s3" {
#     encrypt = true
#   }
# }

locals {
  production_availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

# This is the entry. It tells Terrraform to use AWS as provider
provider "aws" {
  profile = "${var.profile}"
  region  = "${var.region}"
  version = "~> 1.16"
}

# The order of modules is not important, but it would be better that modules are ordered like you setup them on the AWS. 

# Setup 

module "defaults" {
  source = "./terraform/defaults"
  region = "${var.region}"
  cidr   = "${var.cidr}"
}

resource "aws_key_pair" "key" {
  key_name   = "${var.key_name}"
  public_key = "${file("public_key.pub")}"
}

# module "vpc" {
#   source            = "./terraform/vpc"
#   name              = "${var.name}"
#   environment       = "${var.environment}"
#   region            = "${var.region}"
#   cidr              = "${var.cidr}"
#   availability_zone = "${local.production_availability_zones}"
# }

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.name}"
  cidr = "10.0.0.0/16"

  azs             = "${local.production_availability_zones}"
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "${var.environment}"
  }
}

module "security_groups" {
  source      = "./terraform/security_groups"
  name        = "${var.name}"
  environment = "${var.environment}"
  vpc_id      = "${module.vpc.vpc_id}"
}

# module "bastion" {
#   source          = "./terraform/bastion"
#   name            = "${var.name}"
#   environment     = "${var.environment}"
#   region          = "${var.region}"
#   instance_type   = "${var.bastion_instance_type}"
#   security_groups = "${module.security_groups.bastion}"
#   vpc_id          = "${module.vpc.vpc_id}"
#   subnet_id       = "${element(module.vpc.public_subnets, 0)}"
#   key_name        = "${var.key_name}"
# }

# module "dhcp" {
#   source  = "./terraform/dhcp"
#   name    = "${module.dns.name}"
#   vpc_id  = "${module.vpc.id}"
#   servers = "${coalesce(var.domain_name_servers, module.defaults.domain_name_servers)}"
# }

# module "dns" {
#   source = "./terraform/dns"
#   name   = "${var.domain_name}"
#   vpc_id = "${module.vpc.id}"
# }

module "cloudwatch" {
  source      = "./terraform/cloudwatch"
  name        = "${var.name}"
  environment = "${var.environment}"
}

module "iam-role" {
  source = "./terraform/iam-role"
}

module "ecp" {
  source                 = "./terraform/ecs"
  name                   = "ecp"
  environment            = "${var.environment}"
  region                 = "${var.region}"
  log_group              = "${module.cloudwatch.log_group_name}"
  cpu                    = 1024
  memory                 = 2048
  ecs_execution_role_arn = "${module.iam-role.ecs_execution_role_arn}"
  ecs_autoscale_role_arn = "${module.iam-role.ecs_autoscale_role_arn}"
  vpc_id                 = "${module.vpc.vpc_id}"
  public_subnets         = ["${module.vpc.public_subnets}"]
  security_groups        = ["${module.security_groups.web}", "${module.security_groups.internal}", "${module.security_groups.cluster}"]
}

module "ecp-dns" {
  source      = "./terraform/dns"
  name        = "${var.domain_name}"
  vpc_id      = "${module.vpc.vpc_id}"
  domain      = "ecp.elit.cloud"
  lb_dns_name = "${module.ecp.lb_dns_name}"
  lb_zone_id  = "${module.ecp.lb_zone_id}"
}

module "ecp-codepipeline" {
  source             = "./terraform/code_pipeline"
  name               = "ecp"
  environment        = "${var.environment}"
  region             = "${var.region}"
  github_owner       = "${var.github_owner}"
  github_repo        = "${var.github_repo}"
  github_branch      = "${var.github_branch}"
  github_token       = "${var.github_token}"
  repository_url     = "${module.ecp.repository_url}"
  ecs_service_name   = "${module.ecp.service_name}"
  ecs_cluster_name   = "${module.ecp.cluster_name}"
  run_task_subnet_id = "${module.vpc.private_subnets[0]}"
  security_groups    = ["${module.security_groups.web}", "${module.security_groups.internal}", "${module.security_groups.cluster}"]
}
