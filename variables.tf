variable "dev_plaid_client_id" {
  description = "Plaid Client ID"
  type = string
}

variable "dev_plaid_secret" {
  description = "Plaid Secret"
  type = string
}

variable "dev_plaid_public_key" {
  description = "Plaid Public Key"
  type = string
}

variable "dev_plaid_env" {
  description = "Plaid Env"
  type = string
}

variable "github_organization" {
  description = "Github organization to manage"
  type = string
  default = "bitmatica"
}

variable "github_token" {
  description = "Token to manage github resources"
  type = string
}