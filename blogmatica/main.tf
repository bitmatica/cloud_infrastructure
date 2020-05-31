locals {
  name = "blogmatica"
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