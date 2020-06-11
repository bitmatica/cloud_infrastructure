locals {
  region = "us-west-2"
}

terraform {
  required_version = ">= 0.12.6"
  backend "s3" {
    bucket = "blogmatica-terraform"
    key    = "blogmatica"
    region = "us-west-2"
  }
}

provider "aws" {
  version = ">= 2.28.1"
  region  = local.region
}

provider "github" {
  token        = var.github_token
  organization = var.github_organization
}

provider "random" {
  version = "~> 2.1"
}

provider "local" {
  version = "~> 1.2"
}

provider "null" {
  version = "~> 2.1"
}

module "blogmatica" {
  source = "./blogmatica"
  plaid_client_id = var.dev_plaid_client_id
  plaid_env = var.dev_plaid_env
  plaid_public_key = var.dev_plaid_public_key
  plaid_secret = var.dev_plaid_secret
  aws_region = local.region
}