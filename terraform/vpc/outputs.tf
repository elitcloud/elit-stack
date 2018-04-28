output "id" {
  description = "The ID of the VPC"
  value       = "${module.vpc.vpc_id}"
}
