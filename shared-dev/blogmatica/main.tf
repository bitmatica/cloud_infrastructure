resource "aws_ecr_repository" "repository" {
  name = var.name
  image_tag_mutability = "IMMUTABLE"
}

data "aws_ecr_image" "image" {
  repository_name = aws_ecr_repository.repository.name
  image_tag       = "latest"
}

// TODO add database to db_instance
//provider "postgresql" {
//  host            = module.database.db_instance_address
//  port            = module.database.db_instance_port
//  username        = module.database.db_instance_username
//  password        = module.database.db_instance_password
//  expected_version = module.database.db_instance_engine_version
//  sslmode         = "require"
//  connect_timeout = 15
//}
//
//resource "postgresql_database" "db" {
//  name = "blogmatica"
//}

module "app" {
  source = "../../modules/eks_app"
  cluster_id = var.cluster_id
  db_host = var.db_host
  db_name = var.db_name
  db_password = var.db_password
  db_port = var.db_port
  db_username = var.db_username
  name = var.name
  environment = var.name
  image = data.aws_ecr_image.image
}