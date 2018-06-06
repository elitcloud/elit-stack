/*====
Cloudwatch Log Group
======*/
resource "aws_cloudwatch_log_group" "main" {
  name = "${var.name}"

  tags {
    Environment = "${var.environment}"
    Application = "${var.name}"
  }
}
