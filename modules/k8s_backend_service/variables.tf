variable "name" {
  description = "Name of the app"
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

variable "creation_depends_on" {
  description = "A hack since terraform modules don't currently support depends_on semantics.  Anything passed here will be required for initial manifest resource creation"
  type = any
  default = null
}

variable "acm_certificate_arn" {
  description = "ARN of ACM certificate to associate with LoadBalancer service"
  type = string
}

variable "plaid_client_id" {
  description = "Plaid Client ID"
  type = string
}

variable "plaid_secret" {
  description = "Plaid Secret"
  type = string
}

variable "plaid_public_key" {
  description = "Plaid Public Key"
  type = string
}

variable "plaid_env" {
  description = "Plaid Env"
  type = string
}

variable "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  type        = string
}
