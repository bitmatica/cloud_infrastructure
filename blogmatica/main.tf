resource "random_string" "suffix" {
  length  = 8
  special = false
  upper = false
}

locals {
  name = "blogmatica-${random_string.suffix.result}"
}

resource "aws_ecr_repository" "repository" {
  name = local.name
  image_tag_mutability = "IMMUTABLE"
}

module "dev" {
  source = "./dev"
  environment = "dev"
  name = local.name
  plaid_client_id = var.plaid_client_id
  plaid_env = var.plaid_env
  plaid_public_key = var.plaid_public_key
  plaid_secret = var.plaid_secret
}