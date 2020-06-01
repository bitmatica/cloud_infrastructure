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
}