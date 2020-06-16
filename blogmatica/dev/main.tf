locals {
  environment = "dev"
  app_name = data.terraform_remote_state.shared.outputs.app_name
  aws_region = data.terraform_remote_state.shared.outputs.aws_region
  name = "${local.app_name}-${random_string.suffix.result}"
  project_name = "${local.environment}-${local.name}"
  public_hosted_zone = "bitmatica.com"
  api_subdomain = "api.${local.project_name}"
  api_uri = "${local.api_subdomain}.${local.public_hosted_zone}"
  frontend_uri = "${local.project_name}.${local.public_hosted_zone}"
  secrets_name = "${local.app_name}-${local.environment}"
}

terraform {
  required_version = ">= 0.12.6"
  backend "s3" {
    bucket = "bitmatica-terraform"
    key    = "blogmatica/dev/terraform.tfstate"
    region = "us-west-2"
    dynamodb_table = "bitmatica-terraform-locks"
    encrypt        = true
  }
}

data "terraform_remote_state" "shared" {
  backend = "s3"
  config = {
    bucket = "bitmatica-terraform"
    key    = "blogmatica/shared/terraform.tfstate"
    region = "us-west-2"
  }
}

provider "aws" {
  version = ">= 2.28.1"
  region  = local.aws_region
}

provider "random" {
  version = "~> 2.1"
}

provider "local" {
  version = "~> 1.2"
}

provider "null" {
  version = "~> 2.1"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper = false
}

resource "random_string" "db_name" {
  length = 16
  special = false
}

resource "random_string" "db_username" {
  length = 16
  special = false
  number = false
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
  map_users = [
    {
      userarn  = "arn:aws:iam::636934759355:user/github-actions-terraform"
      username = "github-actions-terraform"
      groups   = ["system:masters"]
    },
  ]
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

data "aws_secretsmanager_secret" "secret" {
  name = local.secrets_name
}

data "aws_secretsmanager_secret_version" "secrets_json" {
  secret_id = data.aws_secretsmanager_secret.secret.id
}

module "backend" {
  source = "../../modules/k8s_backend_service"
  db_host = module.db_instance.db_instance_address
  db_name = module.db_instance.db_instance_name
  db_password = module.db_instance.db_instance_password
  db_port = module.db_instance.db_instance_port
  db_username = module.db_instance.db_instance_username
  name = local.name
  image = local.backend_image
  providers = {
    // Ensure cluster for this environment is used
    kubernetes = kubernetes.blogmaticadev
  }
  // Hack to ensure cluster is ready before creating k8s resources
  creation_depends_on = module.cluster.config_map_aws_auth
  acm_certificate_arn = module.backend_cert.acm_certificate_arn
  plaid_client_id = jsondecode(data.aws_secretsmanager_secret_version.secrets_json.secret_string)["plaid_client_id"]
  plaid_env = jsondecode(data.aws_secretsmanager_secret_version.secrets_json.secret_string)["plaid_env"]
  plaid_public_key = jsondecode(data.aws_secretsmanager_secret_version.secrets_json.secret_string)["plaid_public_key"]
  plaid_secret = jsondecode(data.aws_secretsmanager_secret_version.secrets_json.secret_string)["plaid_secret"]
  cluster_oidc_issuer_url = module.cluster.cluster_oidc_issuer_url
}

module "subdomain" {
  source = "../../modules/route53_subdomain"
  hostname = module.backend.service_host
  subdomain = local.api_subdomain
}

module "backend_cert" {
  source = "../../modules/acm_certificate"
  domain_name = local.api_uri
  public_hosted_zone_domain_name = local.public_hosted_zone
}

module "frontend" {
  source = "../../modules/s3_static_site"
  bucket_name =  data.terraform_remote_state.shared.outputs.dev_frontend_bucket_name
  domain_name = local.frontend_uri
  public_hosted_zone_domain_name = local.public_hosted_zone
  frontend_version = local.frontend_version
}