/*
  This vpc moudle inherit the source: https://github.com/terraform-aws-modules/terraform-aws-vpc

  We only create public and private subnets in our stack. Not sure do we need to seperate subnest by services, eg. database_subnets.

  The CIRD block of the VPC use 10.0.0.0/16 as default 
  Public subnets use CIRD blocks: 10.0.0.0/24, 10.0.1.0/24, 10.0.2.0/24
  Private subnets use  CIDR blocks: 10.0.100.0/24, 10.0.101.0/24, 10.0.102.0/24

  NAT gateway is enable for private subnets connection. 

  # TODO: 
    - azs should be flexible 
    - public_subnest and private_subnets settings should be flexible
 */
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.name}-vpc"
  cidr = "${var.cidr}"

  azs             = ["${format("%sa", var.region)}", "${format("%sb", var.region)}", "${format("%sc", var.region)}"]
  public_subnets  = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.100.0/24", "10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "${var.environment}"
  }
}
