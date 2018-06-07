output "ecs_execution_role_arn" {
  value = "${aws_iam_role.ecs_execution_role.arn}"
}

output "ecs_autoscale_role_arn" {
  value = "${aws_iam_role.ecs_autoscale_role.arn}"
}
