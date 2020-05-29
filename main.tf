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

data "aws_availability_zones" "available" {
}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.6"

  name                 = "test-vpc"
  cidr                 = var.cidr
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = var.public_subnets
  private_subnets      = var.private_subnets

  enable_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name = var.cluster_name
  # EKS master nodes will look for public subnets
  # with tags "kubernetes.io/cluster/${local.cluster_name}" = "shared" and "kubernetes.io/role/elb" = "1"
  # when creating load balancers.
  # This variable is used to determine which subnets to launch worker nodes into,
  # so we only include private subnets.
  # See discussion: https://github.com/terraform-aws-modules/terraform-aws-eks/issues/104
  subnets      = module.vpc.private_subnets

  vpc_id = module.vpc.vpc_id

  write_kubeconfig = false

  node_groups = {
    main = {
      # desired_capacity is just the initial value and updates are ignored by this module.
      # The preferred way to manage capacity is with k8s auto scaling.
      // TODO support autoscaling
      desired_capacity = 2
      max_capacity     = 2
      min_capacity     = 1

      instance_type = var.instance_type
    }
  }
  map_roles    = var.map_roles
  map_users    = var.map_users
  map_accounts = var.map_accounts
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.11.1"
}

resource "kubernetes_service" "service" {
  depends_on = [module.eks.node_groups]
  metadata {
    name = "blogmatica"
  }
  spec {
    selector = {
      app = "blogmatica"
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
    name = "blogmatica"
    labels = {
      app = "blogmatica"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "blogmatica"
      }
    }
    template {
      metadata {
        labels = {
          app = "blogmatica"
        }
      }

      spec {
        container {
          image = "636934759355.dkr.ecr.us-east-1.amazonaws.com/nest-blogmatica:6983c3d879f8a15530eb78290776655a0d6e4275"
          name = "blogmatica"
          port {
            container_port = 3000
          }

//          env {
//            name = "DATABASE_HOST"
//            value = var.db_host
//          }
//          env {
//            name = "DATABASE_PORT"
//            value = var.db_port
//          }
//          env {
//            name = "DATABASE_USER"
//            value = var.db_username
//          }
//          env {
//            name = "DATABASE_PASS"
//            value = var.db_password
//          }
//          env {
//            name = "DATABASE_DB"
//            value = var.db_name
//          }
//          env {
//            name = "DATABASE_MIGRATIONS"
//            value = "true"
//          }
          image_pull_policy = "Always"
        }
      }
    }
  }
}
