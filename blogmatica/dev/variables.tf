variable "name" {
  description = "Name of the app"
  type = string
}

variable "environment" {
  description = "Environment of the app, such as dev"
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