terraform {
  required_version = ">= 0.12.6"
}

provider "aws" {
  version = ">= 2.28.1"
  region  = var.region
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

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.11"
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

locals {
  cluster_name = "${var.app_name}-${var.environment}-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc" {
  source = "./modules/vpc"
  cluster_name = local.cluster_name
}

module "eks" {
  source = "./modules/eks"
  vpc_id = module.vpc.vpc_id
  worker_node_subnets = module.vpc.private_subnets
  cluster_name = local.cluster_name
}

module "rds" {
  source = "./modules/rds"
  db_identifier = var.app_name
  db_name = var.app_name
  db_username = "demouser"
  db_password = "demopassword"
  db_port = "5432"
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  ingress_security_group_id = module.eks.cluster_worker_security_group_id
}

module "route53" {
  source = "./modules/route53"
  subdomain = "${var.app_name}.${var.environment}"
  hostname = kubernetes_service.service.load_balancer_ingress.0.hostname
}

resource "kubernetes_service" "service" {
  metadata {
    name = var.app_name
  }
  spec {
    selector = {
      app = var.app_name
    }
    port {
      port = 80
      target_port = 3000
    }
    type = "LoadBalancer"
  }
}

resource "kubernetes_deployment" "deployment" {
  metadata {
    name = var.app_name
    labels = {
      app = var.app_name
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = var.app_name
      }
    }
    template {
      metadata {
        labels = {
          app = var.app_name
        }
      }

      spec {
        container {
          image = var.app_image
          name = var.app_name
          port {
            container_port = 3000
          }
          env {
            name = "DATABASE_HOST"
            value = module.rds.this_db_instance_address
          }
          env {
            name = "DATABASE_PORT"
            value = module.rds.this_db_instance_port
          }
          env {
            name = "DATABASE_USER"
            value = module.rds.this_db_instance_username
          }
          env {
            name = "DATABASE_PASS"
            value = module.rds.this_db_instance_password
          }
          env {
            name = "DATABASE_DB"
            value = module.rds.this_db_instance_name
          }
          env {
            name = "DATABASE_MIGRATIONS"
            value = "true"
          }
          image_pull_policy = "Always"
        }
      }
    }
  }
}
