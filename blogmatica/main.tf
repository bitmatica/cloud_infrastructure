locals {
  app_name = "blogmatica"
}

module "dev" {
  source = "./dev"
  app_name = local.app_name
  environment = "dev"
}