resource "random_string" "suffix" {
  length  = 8
  special = false
  upper = false
}

locals {
  name = "blogmatica-${random_string.suffix.result}"
  github_backend_repository_name = "nest-blogmatica"
  github_frontend_repository_name = "blogmatica-mst-apollo"
}

resource "aws_ecr_repository" "repository" {
  name = local.name
  image_tag_mutability = "IMMUTABLE"
}

module "github_actions_backend_cd_secrets" {
  source = "../modules/github_actions_ecr_secrets"
  aws_region = var.aws_region
  ecr_repository_name = aws_ecr_repository.repository.name
  github_repository_name = local.github_backend_repository_name
}

module "github_actions_frontend_cd_secrets" {
  source = "../modules/github_actions_s3_secrets"
  aws_region = var.aws_region
  github_repository_name = local.github_frontend_repository_name
  public_url = "https://${module.dev.frontend_hostname}"
  s3_bucket_name = module.dev.frontend_s3_bucket_name
  // TODO This necessitates a FE build per env.  Look into alternatives
  server_uri = "https://${module.dev.app_hostname}/graphql"
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
