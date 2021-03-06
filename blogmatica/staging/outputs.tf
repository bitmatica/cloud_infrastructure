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

output "db_instance_id" {
  description = "ID of the db instance"
  value       = module.db_instance.this_db_instance_id
}

output "app_hostname" {
  description = "Hostname of kubernetes app"
  value = module.subdomain.hostname
}

output "frontend_hostname" {
  description = "Hostname of frontend app"
  value = module.frontend.hostname
}

output "frontend_s3_bucket_name" {
  description = "Name of s3 bucket that CloudFront points to"
  value = module.frontend.s3_bucket_name
}