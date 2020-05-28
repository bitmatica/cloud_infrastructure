variable "cluster_id" {
  description = "The ID of the cluster to apply deployment config"
  type = string
}

variable "name" {
  description = "Name of deployment"
  type = string
}

variable "image" {
  description = "Image to schedule on pods"
  type = string
}

variable "replicas" {
  description = "Number of pod replicas"
  type = number
  default = 1
}

// TODO Figure out how to accept multiple env blocks like k8s deployment resource does
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
