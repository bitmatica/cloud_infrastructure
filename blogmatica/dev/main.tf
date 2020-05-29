resource "random_string" "suffix" {
  length  = 8
  special = false
}

locals {
  project_name = "${var.name}-${var.environment}"
}

locals {
  cluster_name = "${local.project_name}-eks-${random_string.suffix.result}"
}

module "app" {
  source = "../../modules/app"
  name = var.name
  environment = var.environment
  db_identifier = "blogmatica"
  db_name = "blogmatica"
  db_username = "demouser"
  db_password = "demopassword"
  db_port = "5432"
  image = local.image
  cluster_name = local.project_name
}
