locals {
  region = "us-west-2"
  github_backend_repository_name = "nest-blogmatica"
  github_frontend_repository_name = "blogmatica-mst-apollo"
}

terraform {
  required_version = ">= 0.12.6"
  backend "s3" {
    bucket = "bitmatica-terraform"
    key    = "blogmatica/shared/terraform.tfstate"
    region = "us-west-2" // No variables allowed here :(
    dynamodb_table = "bitmatica-terraform-locks"
    encrypt        = true
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

resource "aws_ecr_repository" "repository" {
  name = "blogmatica"
  image_tag_mutability = "IMMUTABLE"
}

data "terraform_remote_state" "dev" {
  backend = "s3"
  config = {
    bucket = "bitmatica-terraform"
    key    = "blogmatica/dev/terraform.tfstate"
    region = "us-west-2"
  }
}

module "github_actions_backend_cd_secrets" {
  source = "../../modules/github_actions_ecr_secrets"
  aws_region = local.region
  ecr_repository_name = aws_ecr_repository.repository.name
  github_repository_name = local.github_backend_repository_name
}

module "github_actions_frontend_cd_secrets" {
  source = "../../modules/github_actions_s3_secrets"
  aws_region = local.region
  github_repository_name = local.github_frontend_repository_name
  public_url = "https://${data.terraform_remote_state.dev.outputs.frontend_hostname}"
  s3_bucket_name = data.terraform_remote_state.dev.outputs.frontend_s3_bucket_name
  // TODO This necessitates a FE build per env.  Look into alternatives
  server_uri = "https://${data.terraform_remote_state.dev.outputs.app_hostname}/graphql"
}
