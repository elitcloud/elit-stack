// The region in which the infra lives.
output "region" {
  value = "${var.region}"
}

// The bastion host IP.
output "bastion_ip" {
  value = "${module.bastion.external_ip}"
}

// The internal route53 zone ID.
output "zone_id" {
  value = "${module.dns.zone_id}"
}
