resource "aws_route53_delegation_set" "main" {
  reference_name = "DynDNS"
}

resource "aws_route53_zone" "main" {
  name    = "${var.name}"
  vpc_id  = "${var.vpc_id}"
  comment = ""
}

resource "aws_route53_record" "main" {
  zone_id = "${aws_route53_zone.main.id}"
  name    = "${var.domain}"
  type    = "A"

  alias {
    name                   = "${var.lb_dns_name}"
    zone_id                = "${var.lb_zone_id}"
    evaluate_target_health = true
  }
}
