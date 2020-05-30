output "db_instance_name" {
  description = "The database name"
  value       = module.rds.this_db_instance_name
}

output "db_instance_username" {
  description = "The master username for the database"
  value       = module.rds.this_db_instance_username
}

output "db_instance_password" {
  description = "The database password (this password may be old, because Terraform doesn't track it after initial creation)"
  value       = module.rds.this_db_instance_password
  sensitive   = true
}

output "db_instance_port" {
  description = "The database port"
  value       = module.rds.this_db_instance_port
}

output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = module.rds.this_db_instance_address
}

output "db_instance_engine_version" {
  description = "The engine version of the RDS instance"
  value       = var.engine_version
}