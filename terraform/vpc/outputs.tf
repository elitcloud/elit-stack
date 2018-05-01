output "id" {
  description = "The ID of the VPC"
  value       = "${aws_vpc.main.id}"
}

output "cidr_block" {
  value = "${aws_vpc.main.cidr_block}"
}

output "public_subnets" {
  value = ["${aws_subnet.public_subnets.*.id}"]
}

output "private_subnets" {
  value = ["${aws_subnet.private_subnets.*.id}"]
}

output "security_group" {
  value = "${aws_vpc.main.default_security_group_id}"
}

output "availability_zones" {
  value = ["${aws_subnet.public_subnets.*.availability_zone}"]
}

output "internet_gateway_route_table_id" {
  value = "${aws_route_table.internet_gateway.id}"
}

output "nat_gateway_route_table_id" {
  value = "${join(",", aws_route_table.nat_gateway.*.id)}"
}

output "internal_nat_ips" {
  value = ["${aws_eip.nat.*.public_ip}"]
}
