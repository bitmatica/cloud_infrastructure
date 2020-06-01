output "dev_vpc_id" {
  description = "ID of created VPC"
  value = module.dev.vpc_id
}

output "dev_public_subnets" {
  description = "A list of public subnets inside the VPC"
  value = module.dev.public_subnets
}

output "dev_private_subnets" {
  description = "A list of private subnets inside the VPC"
  value = module.dev.private_subnets
}

output "dev_cluster_id" {
  description = "ID of created cluster"
  value       = module.dev.cluster_id
}

output "dev_cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.dev.cluster_endpoint
}

output "dev_db_instance_name" {
  description = "The database name"
  value       = module.dev.db_instance_name
}

output "dev_app_hostname" {
  description = "Hostname of kubernetes app"
  value = module.dev.app_hostname
}