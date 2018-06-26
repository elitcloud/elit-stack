data "aws_acm_certificate" "example" {
  domain      = "*.elit.cloud"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}
