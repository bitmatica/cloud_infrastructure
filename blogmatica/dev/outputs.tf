output "vpc_id" {
  description = "ID of created VPC"
  value = module.network.vpc_id
}

output "public_subnets" {
  description = "A list of public subnets inside the VPC"
  value = module.network.public_subnets
}

output "private_subnets" {
  description = "A list of private subnets inside the VPC"
  value = module.network.private_subnets
}

output "cluster_id" {
  description = "ID of created cluster"
  value       = module.cluster.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.cluster.cluster_endpoint
}

output "db_instance_name" {
  description = "The database name"
  value       = module.db_instance.db_instance_name
}

output "app_hostname" {
  description = "Hostname of kubernetes app"
  value = module.subdomain.hostname
}