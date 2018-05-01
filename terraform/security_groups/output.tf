output "web" {
  value = "${aws_security_group.web.id}"
}

output "bastion" {
  value = "${aws_security_group.bastion.id}"
}

output "internal" {
  value = "${aws_security_group.internal.id}"
}

output "internal_ssh" {
  value = "${aws_security_group.internal_ssh.id}"
}

output "psql" {
  value = "${aws_security_group.psql.id}"
}

output "redis" {
  value = "${aws_security_group.redis.id}"
}

output "efs" {
  value = "${aws_security_group.efs.id}"
}
