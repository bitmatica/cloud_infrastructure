// TODO unfortunate to have to re-export these across module boundaries.  Maybe there's a better way.
output "blogmatica_dev_vpc_id" {
  description = "ID of created VPC"
  value = module.blogmatica.dev_vpc_id
}

output "blogmatica_dev_public_subnets" {
  description = "A list of public subnets inside the VPC"
  value = module.blogmatica.dev_public_subnets
}

output "blogmatica_dev_private_subnets" {
  description = "A list of private subnets inside the VPC"
  value = module.blogmatica.dev_private_subnets
}

output "blogmatica_dev_cluster_id" {
  description = "ID of created cluster"
  value       = module.blogmatica.dev_cluster_id
}

output "blogmatica_dev_cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.blogmatica.dev_cluster_endpoint
}

output "blogmatica_dev_db_instance_id" {
  description = "ID of the db instance"
  value       = module.blogmatica.dev_db_instance_id
}

output "blogmatica_dev_app_hostname" {
  description = "Hostname of kubernetes app"
  value = module.blogmatica.dev_app_hostname
}

output "region" {
  description = "AWS region"
  value = local.region
}