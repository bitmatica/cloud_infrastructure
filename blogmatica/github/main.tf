locals {
  app_name = data.terraform_remote_state.shared.outputs.app_name
  aws_region = data.terraform_remote_state.shared.outputs.aws_region
  github_backend_repository_name = "nest-blogmatica"
  github_frontend_repository_name = "blogmatica-mst-apollo"
  github_organization = "bitmatica"
  github_terraform_repository_name = "cloud_infrastructure"
}

data "aws_secretsmanager_secret" "secret" {
  name = data.terraform_remote_state.shared.outputs.github_secrets_name
}

data "aws_secretsmanager_secret_version" "secrets_json" {
  secret_id = data.aws_secretsmanager_secret.secret.id
}

terraform {
  required_version = ">= 0.12.6"
  backend "s3" {
    bucket = "bitmatica-terraform"
    key    = "blogmatica/github/terraform.tfstate"
    region = "us-west-2" // No variables allowed here :(
    dynamodb_table = "bitmatica-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  version = ">= 2.28.1"
  region  = local.aws_region
}

provider "github" {
  token        = jsondecode(data.aws_secretsmanager_secret_version.secrets_json.secret_string)["github_token"]
  organization = var.github_organization
}

data "terraform_remote_state" "dev" {
  backend = "s3"
  config = {
    bucket = "bitmatica-terraform"
    key    = "blogmatica/dev/terraform.tfstate"
    region = "us-west-2"
  }
}

data "terraform_remote_state" "shared" {
  backend = "s3"
  config = {
    bucket = "bitmatica-terraform"
    key    = "blogmatica/shared/terraform.tfstate"
    region = "us-west-2"
  }
}

module "github_actions_backend_cd_secrets" {
  source = "../../modules/github_actions_ecr_secrets"
  aws_region = local.aws_region
  ecr_repository_name = data.terraform_remote_state.shared.outputs.ecr_repository_name
  github_repository_name = local.github_backend_repository_name
  terraform_github_repository_name = local.github_terraform_repository_name
  terraform_github_repository_org_name = local.github_organization
  terraform_github_repository_version_path = "${local.app_name}/dev/backend_version.txt"
}

module "github_actions_frontend_cd_secrets" {
  source = "../../modules/github_actions_s3_secrets"
  aws_region = local.aws_region
  github_repository_name = local.github_frontend_repository_name
  dev_public_url = "https://${data.terraform_remote_state.dev.outputs.frontend_hostname}"
  dev_s3_bucket_name = data.terraform_remote_state.dev.outputs.frontend_s3_bucket_name
  // TODO This necessitates a FE build per env.  Look into alternatives
  dev_server_uri = "https://${data.terraform_remote_state.dev.outputs.app_hostname}/graphql"
  terraform_github_repository_name = local.github_terraform_repository_name
  terraform_github_repository_org_name = local.github_organization
  terraform_github_repository_dev_version_path = "${local.app_name}/dev/frontend_version.txt"
}
