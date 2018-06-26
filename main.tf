provider "aws" {
  profile = "${var.profile}"
  region  = "${var.region}"
  version = "~> 1.16"
}

locals {
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.name}"
  cidr = "${var.vpc_cidr}"

  azs             = "${local.availability_zones}"
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "${var.environment}"
  }
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = "${module.vpc.vpc_id}"
}

module "web_security_group" {
  source              = "terraform-aws-modules/security-group/aws//modules/web"
  name                = "web_security_group"
  vpc_id              = "${module.vpc.vpc_id}"
  ingress_cidr_blocks = ["0.0.0.0/0"]
}

module "nfs_security_group" {
  source              = "terraform-aws-modules/security-group/aws//modules/nfs"
  name                = "nfs_security_group"
  vpc_id              = "${module.vpc.vpc_id}"
  ingress_cidr_blocks = ["${var.vpc_cidr}"]
}

module "redis_security_group" {
  source              = "terraform-aws-modules/security-group/aws//modules/redis"
  name                = "redis_security_group"
  vpc_id              = "${module.vpc.vpc_id}"
  ingress_cidr_blocks = ["${var.vpc_cidr}"]
}

module "postgresql_security_group" {
  source              = "terraform-aws-modules/security-group/aws//modules/postgresql"
  name                = "postgresql_security_group"
  vpc_id              = "${module.vpc.vpc_id}"
  ingress_cidr_blocks = ["${var.vpc_cidr}"]
}

module "ssh_security_group" {
  source              = "terraform-aws-modules/security-group/aws//modules/ssh"
  name                = "ssh_security_group"
  vpc_id              = "${module.vpc.vpc_id}"
  ingress_cidr_blocks = ["0.0.0.0/0"]
}

module "cloudwatch" {
  source      = "modules/cloudwatch"
  name        = "${var.name}"
  environment = "${var.environment}"
}
