/*
  This vpc moudle inherit the source: https://github.com/terraform-aws-modules/terraform-aws-vpc

  We only create public and private subnets in our stack. Not sure do we need to seperate subnest by services, eg. database_subnets.

  The CIRD block of the VPC use 10.0.0.0/16 as default 
  Public subnets use CIRD blocks: 10.0.0.0/24, 10.0.1.0/24, 10.0.2.0/24
  Private subnets use  CIDR blocks: 10.0.100.0/24, 10.0.101.0/24, 10.0.102.0/24

  NAT gateway is enable for private subnets connection. 

  # TODO: 
    - azs should be flexible 
    - public_subnets and private_subnets settings should be flexible
  */

# VPC

resource "aws_vpc" "main" {
  cidr_block           = "${var.cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name        = "${var.name}"
    Environment = "${var.environment}"
  }
}

# Internet Gateway

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name        = "${var.name}"
    Environment = "${var.environment}"
  }
}

# NAT Gateway

resource "aws_nat_gateway" "main" {
  count         = "${length(var.private_subnets)}"
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public_subnets.*.id, count.index)}"
  depends_on    = ["aws_internet_gateway.main"]

  tags {
    Name        = "${var.name}"
    Environment = "${var.environment}"
  }
}

resource "aws_eip" "nat" {
  count = "${length(var.private_subnets)}"
  vpc   = true

  tags {
    Name        = "${var.name}"
    Environment = "${var.environment}"
  }
}

# Subnets

# Public subnet

resource "aws_subnet" "public_subnets" {
  count                   = "${length(var.public_subnets)}"
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${element(var.public_subnets, count.index)}"
  availability_zone       = "${element(var.availability_zone, count.index)}"
  map_public_ip_on_launch = true

  tags {
    Name        = "${var.name}-${format("public-%d", count.index+1)}"
    Environment = "${var.environment}"
  }
}

resource "aws_subnet" "private_subnets" {
  count             = "${length(var.private_subnets)}"
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${element(var.private_subnets, count.index)}"
  availability_zone = "${element(var.availability_zone, count.index)}"

  tags {
    Name        = "${var.name}-${format("private-%d", count.index+1)}"
    Environment = "${var.environment}"
  }
}

# Routing

# Route table

resource "aws_route" "internet_gateway" {
  route_table_id         = "${aws_route_table.internet_gateway.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.main.id}"
}

resource "aws_route_table" "internet_gateway" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name        = "${var.name}-interet-gateway"
    Environment = "${var.environment}"
  }
}

resource "aws_route" "nat_gateway" {
  count                  = "${length(var.private_subnets)}"
  route_table_id         = "${element(aws_route_table.nat_gateway.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${element(aws_nat_gateway.main.*.id, count.index)}"
}

resource "aws_route_table" "nat_gateway" {
  count  = "${length(var.private_subnets)}"
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name        = "${var.name}-${format("nat-gateway-%d", count.index+1)}"
    Environment = "${var.environment}"
  }
}

# Route table association 

resource "aws_route_table_association" "public" {
  count = "${length(var.public_subnets)}"

  subnet_id      = "${element(aws_subnet.public_subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.internet_gateway.id}"
}

resource "aws_route_table_association" "private" {
  count = "${length(var.private_subnets)}"

  subnet_id      = "${element(aws_subnet.private_subnets.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.nat_gateway.*.id, count.index)}"
}
