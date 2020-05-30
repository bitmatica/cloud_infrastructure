resource "random_string" "suffix" {
  length  = 8
  special = false
}

locals {
  project_name = "shared-dev-${random_string.suffix.result}"
}

module "network" {
  source = "../modules/eks_vpc"
  name = local.project_name
  cluster_name = local.project_name
}

module "cluster" {
  source = "../modules/autoscaling_eks"
  cluster_name = local.project_name
  vpc_id = module.network.vpc_id
  worker_node_subnet_ids = module.network.private_subnets
}

module "db_instance" {
  source = "../modules/postgres_rds"
  identifier = "dev"
  ingress_security_group_id = module.cluster.cluster_worker_nodes_security_group_id
  name = "demodb"
  username = "demouser"
  password = "demopassword"
  vpc_id = module.network.vpc_id
  subnet_ids = module.network.private_subnets
}

module "blogmatica" {
  source = "./blogmatica"
  cluster_id = module.cluster.cluster_id
  db_host = module.db_instance.db_instance_address
  db_name = module.db_instance.db_instance_name
  db_password = module.db_instance.db_instance_password
  db_port = module.db_instance.db_instance_port
  db_username = module.db_instance.db_instance_username
  name = "blogmatica"
  environment = "dev"
}