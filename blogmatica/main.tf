locals {
  app_name = "blogmatica"
}

module "dev" {
  source = "./dev"
  name = local.app_name
  environment = "dev"
}