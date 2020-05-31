variable "vpc_id" {
  description = "ID of VPC that EKS cluster will be created in"
  type = string
}

variable "identifier" {
  description = "The name of the RDS instance, if omitted, Terraform will assign a random, unique identifier"
  type        = string
}

variable "name" {
  description = "The DB name to create. If omitted, no database is created initially"
  type        = string
  default     = ""
}

variable "username" {
  description = "Username for the master DB user"
  type        = string
}

variable "password" {
  description = "Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file"
  type        = string
}

variable "ingress_security_group_id" {
  description = "A security group to allow ingress from"
  type        = string
}

variable "ingress_security_group_description" {
  description = "A security group to allow ingress from"
  type        = string
  default     = "Allow EKS worker nodes to communicate with database"
}

variable "port" {
  description = "The port on which the DB accepts connections"
  type        = string
  default = "5432"
}

variable "subnet_ids" {
  description = "Subnet IDs for RDS instance"
  type        = list(string)
}

variable "engine_version" {
  description = "Version of postgres engine"
  type        = string
  default = "11.6"
}

variable "instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
  default = "db.t2.micro"
}