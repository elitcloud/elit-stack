output "repository_url" {
  value = "${aws_ecr_repository.main.repository_url}"
}

output "cluster_name" {
  value = "${aws_ecs_cluster.main.name}"
}

output "service_name" {
  value = "${aws_ecs_service.main.name}"
}

output "lb_dns_name" {
  value = "${aws_lb.main.dns_name}"
}

output "lb_zone_id" {
  value = "${aws_lb.main.zone_id}"
}
