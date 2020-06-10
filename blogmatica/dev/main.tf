locals {
  project_name = "${var.environment}-${var.name}"
  api_uri = "api.${local.project_name}"
}

resource "random_string" "db_name" {
  length = 16
  special = false
}

resource "random_string" "db_username" {
  length = 16
  special = false
}

resource "random_password" "db_password" {
  length = 16
  special = false
}

module "network" {
  source = "../../modules/eks_vpc"
  name = local.project_name
  cluster_name = local.project_name
}

module "cluster" {
  source = "../../modules/autoscaling_eks"
  cluster_name = local.project_name
  vpc_id = module.network.vpc_id
  worker_node_subnet_ids = module.network.private_subnets
}

module "db_instance" {
  source = "../../modules/postgres_rds"
  identifier = local.project_name
  ingress_security_group_id = module.cluster.cluster_worker_nodes_security_group_id
  name = random_string.db_name.result
  username = random_string.db_username.result
  password = random_password.db_password.result
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
  image = local.backend_image
  providers = {
    // Ensure cluster for this environment is used
    kubernetes = kubernetes.blogmaticadev
  }
  // Hack to ensure cluster is ready before creating k8s resources
  creation_depends_on = module.cluster.config_map_aws_auth
  acm_certificate_arn = module.backend_cert.acm_certificate_arn
  plaid_client_id = var.plaid_client_id
  plaid_env = var.plaid_env
  plaid_public_key = var.plaid_public_key
  plaid_secret = var.plaid_secret
  cluster_oidc_issuer_url = module.cluster.cluster_oidc_issuer_url
}

module "subdomain" {
  source = "../../modules/route53_subdomain"
  hostname = module.app.service_host
  subdomain = local.api_uri
}

module "backend_cert" {
  source = "../../modules/acm_certificate"
  domain_name = "${local.api_uri}.bitmatica.com"
  public_hosted_zone_domain_name = "bitmatica.com."
}

module "frontend" {
  source = "../../modules/s3_static_site"
  name =  local.project_name
  domain_name = "${local.project_name}.bitmatica.com"
  public_hosted_zone_domain_name = "bitmatica.com."
  frontend_version = local.frontend_version
}
