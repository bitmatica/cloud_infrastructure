variable "vpc_id" {
  description = "VPC where the cluster and workers will be deployed."
  type = string
}

variable "ingress_security_group_id" {
  description = "ID of security group to allow ingress from"
  type = string
  // TODO This should be locked down to private-only security group.  Why doesn't module.eks.worker_security_group_id work?
  //  source_security_group_id = module.eks.cluster_primary_security_group_id
}

variable "db_identifier" {
  description = "The name of the RDS instance, if omitted, Terraform will assign a random, unique identifier"
  type        = string
}

variable "db_name" {
  description = "The DB name to create."
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

variable "subnet_ids" {
  description = "A list of VPC subnet IDs"
  type        = list(string)
  // TODO module.vpc.private_subnets
}