variable "name" {
  description = "Name of the app"
  type = string
}

variable "environment" {
  description = "Environment of the app, such as dev"
  type = string
}

variable "cluster_id" {
  description = "ID of EKS cluster to deploy to"
  type = string
}

variable "db_host" {
  description = "The host of the RDS instance"
  type        = string
}

variable "db_name" {
  description = "The DB name"
  type        = string
}

variable "db_username" {
  description = "Username for the master DB user"
  type        = string
}

variable "db_password" {
  description = "Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file"
  type        = string
}

variable "db_port" {
  description = "The port on which the DB accepts connections"
  type        = string
}