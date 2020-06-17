locals {
  app_name = "blogmatica"
  github_secrets_name = "${local.app_name}-github"
  dev_frontend_bucket_name = "${local.app_name}-dev-frontend"
  dev_secrets_name = "${local.app_name}-dev"
  staging_frontend_bucket_name = "${local.app_name}-staging-frontend"
  staging_secrets_name = "${local.app_name}-staging"
  region = "us-west-2"
}

terraform {
  required_version = ">= 0.12.6"
  backend "s3" {
    bucket = "bitmatica-terraform"
    key    = "blogmatica/shared/terraform.tfstate"
    region = "us-west-2"
    dynamodb_table = "bitmatica-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  version = ">= 2.28.1"
  region  = local.region
}

resource "aws_ecr_repository" "repository" {
  name = local.app_name
  image_tag_mutability = "IMMUTABLE"
}

resource "aws_secretsmanager_secret" "github_secrets" {
  name = local.github_secrets_name
}

# Note - this bucket will be modified to give CloudFront access
# Bucket is created here so infra can be destroyed without destroying frontend asset bundles
resource "aws_s3_bucket" "dev_bucket" {
  bucket = local.dev_frontend_bucket_name
  # Bucket is not publicly accessible - CloudFront is given access via origin access identity
  acl    = "private"

  tags = {
    Name = local.dev_frontend_bucket_name
  }
  lifecycle {
    # These are updated by s3_static_site module, ignore changes
    ignore_changes = [grant]
  }
}

resource "aws_secretsmanager_secret" "dev_secrets" {
  name = local.dev_secrets_name
}

# Note - this bucket will be modified to give CloudFront access
# Bucket is created here so infra can be destroyed without destroying frontend asset bundles
resource "aws_s3_bucket" "staging_bucket" {
  bucket = local.staging_frontend_bucket_name
  # Bucket is not publicly accessible - CloudFront is given access via origin access identity
  acl    = "private"

  tags = {
    Name = local.staging_frontend_bucket_name
  }
  lifecycle {
    # These are updated by s3_static_site module, ignore changes
    ignore_changes = [grant]
  }
}

resource "aws_secretsmanager_secret" "staging_secrets" {
  name = local.staging_secrets_name
}