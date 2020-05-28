output "this_db_instance_name" {
  description = "The database name"
  value       = module.rds.this_db_instance_name
}

output "this_db_instance_username" {
  description = "The master username for the database"
  value       = module.rds.this_db_instance_username
}

output "this_db_instance_password" {
  description = "The database password (this password may be old, because Terraform doesn't track it after initial creation)"
  value       = module.rds.this_db_instance_password
  sensitive   = true
}

output "this_db_instance_port" {
  description = "The database port"
  value       = module.rds.this_db_instance_port
}

output "this_db_instance_address" {
  description = "The address of the RDS instance"
  value       = module.rds.this_db_instance_address
}