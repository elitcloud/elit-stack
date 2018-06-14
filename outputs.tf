// The region in which the infra lives.
output "region" {
  value = "${var.region}"
}

// The bastion host IP.
# output "bastion_ip" {
#   value = "${module.bastion.external_ip}"
# }

output "lb_dns_name" {
  value = "${module.ecp.lb_dns_name}"
}
