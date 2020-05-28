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

module "network" {
  source = "../../modules/vpc"
  name = "${local.project_name}-vpc"
  cluster_name = local.cluster_name
}

module "cluster" {
  source = "../../modules/eks"
  vpc_id = module.network.vpc_id
  worker_node_subnets = module.network.private_subnets
  cluster_name = local.cluster_name
}

module "database" {
  source = "../../modules/rds"
  db_identifier = var.name
  db_name = var.name
  db_username = "demouser"
  db_password = "demopassword"
  db_port = "5432"
  vpc_id = module.network.vpc_id
  subnet_ids = module.network.private_subnets
  ingress_security_group_id = module.cluster.cluster_worker_security_group_id
}

module "dns" {
  source = "../../modules/route53"
  subdomain = "${var.name}.${var.environment}"
  hostname = module.service.hostname
}

module "service" {
  source = "../../modules/k8s/service"
  cluster_id = module.cluster.cluster_id
  app_name = var.name
}

module "deployment" {
  source = "../../modules/k8s/deployment"
  cluster_id = module.cluster.cluster_id
  name = var.name
  db_host = module.database.this_db_instance_address
  db_name = module.database.this_db_instance_name
  db_password = module.database.this_db_instance_password
  db_port = module.database.this_db_instance_port
  db_username = module.database.this_db_instance_username
  image = local.image
}
