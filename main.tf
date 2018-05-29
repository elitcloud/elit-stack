# https://www.terraform.io/docs/backends/config.html
# terraform {
#   backend "s3" {
#     encrypt = true
#   }
# }

# This is the entry. It tells Terrraform to use AWS as provider
provider "aws" {
  profile = "${var.profile}"
  region  = "${var.region}"
  version = "~> 1.16"
}

# The order of modules is not important, but it would be better that modules are ordered like you setup them on the AWS. 

# Setup 

module "vpc" {
  source            = "./terraform/vpc"
  name              = "${var.name}"
  environment       = "${var.environment}"
  region            = "${var.region}"
  availability_zone = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

module "security_groups" {
  source      = "./terraform/security_groups"
  name        = "${var.name}"
  environment = "${var.environment}"
  vpc_id      = "${module.vpc.id}"
}

module "bastion" {
  source          = "./terraform/bastion"
  name            = "${var.name}"
  environment     = "${var.environment}"
  region          = "${var.region}"
  instance_type   = "${var.bastion_instance_type}"
  security_groups = "${module.security_groups.bastion}"
  vpc_id          = "${module.vpc.id}"
  subnet_id       = "${element(module.vpc.public_subnets, 0)}"
  key_name        = "${var.key_name}"
}
