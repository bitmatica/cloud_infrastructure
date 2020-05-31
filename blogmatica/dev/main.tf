module "network" {
  source = "../../modules/eks_vpc"
  name = var.name
  cluster_name = var.name
}

module "cluster" {
  source = "../../modules/autoscaling_eks"
  cluster_name = var.name
  vpc_id = module.network.vpc_id
  worker_node_subnet_ids = module.network.private_subnets
}

module "db_instance" {
  source = "../../modules/postgres_rds"
  identifier = var.name
  ingress_security_group_id = module.cluster.cluster_worker_nodes_security_group_id
  name = "demodb"
  username = "demouser"
  password = "demopassword"
  vpc_id = module.network.vpc_id
  subnet_ids = module.network.private_subnets
}

provider "kubernetes" {
  alias = "blogmaticadev"
  host                   = module.cluster.cluster_endpoint
  cluster_ca_certificate = module.cluster.cluster_ca_certificate
  token                  = module.cluster.cluster_token
  load_config_file       = false
  version                = "~> 1.11.1"
}

module "app" {
  source = "../manifests"
  db_host = module.db_instance.db_instance_address
  db_name = module.db_instance.db_instance_name
  db_password = module.db_instance.db_instance_password
  db_port = module.db_instance.db_instance_port
  db_username = module.db_instance.db_instance_username
  name = var.name
  image = local.image
  providers = {
    // Ensure cluster for this environment is used
    kubernetes = kubernetes.blogmaticadev
  }
  // Hack to ensure cluster is ready before creating k8s resources
  creation_depends_on = module.cluster.config_map_aws_auth
}

module "subdomain" {
  source = "../../modules/route53_subdomain"
  hostname = module.app.service_host
  subdomain = "${var.name}.${var.environment}"
}
