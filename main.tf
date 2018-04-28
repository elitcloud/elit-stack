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
}

# The order of modules is not important, but it would be better that modules are ordered like you setup them on the AWS. 

# Setup 

module "security_groups" {
  source      = "./terraform/security_groups"
  name        = "${var.name}"
  environment = "${var.environment}"
  vpc_id      = "${module.vpc.id}"
}

module "vpc" {
  source      = "./terraform/vpc"
  name        = "${var.name}"
  environment = "${var.environment}"
  region      = "${var.region}"
}