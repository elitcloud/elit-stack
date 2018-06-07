/* 
  We create multiple security groups basically classified in two parts: External and Internal. 
  
  External security groups allow all trafics connect to services on port 22, 80 and 443. 
  Internal security groups are designed for services inside of it. 
  - Default
  - External:
    - web
    - bastion
  - Internal:
    - internal
    - internal_ssh
    - psql
    - redis
    - efs
 */

# Default

resource "aws_security_group" "default" {
  name        = "${format("%s-%s-default", var.name, var.environment)}"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = "true"
  }

  tags {
    Environment = "${var.environment}"
  }
}

# External
resource "aws_security_group" "web" {
  name        = "${format("%s-%s-web", var.name, var.environment)}"
  description = "Allows external traffic "
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name        = "${format("%s-web", var.name)}"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "bastion" {
  name        = "${format("%s-%s-bastion", var.name, var.environment)}"
  description = "Allows ssh from the world"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.bastion_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name        = "${format("%s-bastion", var.name)}"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "internal" {
  name        = "${format("%s-%s-internal", var.name, var.environment)}"
  vpc_id      = "${var.vpc_id}"
  description = "Allows internal traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name        = "${format("%s-internal", var.name)}"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "internal_ssh" {
  name        = "${format("%s-%s-internal-ssh", var.name, var.environment)}"
  description = "Allows ssh from bastion"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bastion.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name        = "${format("%s-sinternal-ssh", var.name)}"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "psql" {
  name        = "${format("%s-%s-psql", var.name, var.environment)}"
  description = "PostgreSQL"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name        = "${format("%s-psql", var.name)}"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "redis" {
  name        = "${format("%s-%s-redis", var.name, var.environment)}"
  description = "PostgreSQL"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name        = "${format("%s-redis", var.name)}"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "efs" {
  name        = "${format("%s-%s-efs", var.name, var.environment)}"
  description = "EFS"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name        = "${format("%s-efs", var.name)}"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "cluster" {
  name        = "${format("%s-%s-cluster", var.name, var.environment)}"
  description = "Allows traffic from and to the EC2 instances of the ${var.name} ECS cluster"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name        = "${format("%s-cluster", var.name)}"
    Environment = "${var.environment}"
  }
}
