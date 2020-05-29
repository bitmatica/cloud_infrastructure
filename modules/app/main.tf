##################
# VPC
##################
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
    // Required so k8s can discover the subnet
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    // Required so k8s can create public load balancers
    "kubernetes.io/role/elb"                      = "1"
  }

  // These tags are required by EKS to schedule worker nodes
  private_subnet_tags = {
    // Required so k8s can discover the subnet
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    // Required so k8s can create internal load balancers
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

##################
# EKS
##################
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

##################
# RDS
##################
resource "aws_security_group" "rds_security_group" {
  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group_rule" "rds_ingress_from_eks" {
  description = "Allow EKS worker nodes to communicate with database"
  from_port = 5432
  protocol = "tcp"
  security_group_id = aws_security_group.rds_security_group.id
  to_port = 5432
  type = "ingress"
  // TODO This should be locked down to private-only security group.  Why doesn't module.eks.worker_security_group_id work?
  source_security_group_id = module.eks.cluster_primary_security_group_id
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 2.0"

  engine            = "postgres"
  engine_version    = "11.6"
  instance_class    = "db.t2.micro"
  allocated_storage = 5


  identifier = var.db_identifier
  name     = var.db_name
  username = var.db_username
  password = var.db_password
  port     = var.db_port

  iam_database_authentication_enabled = true
  skip_final_snapshot = true

  vpc_security_group_ids = [aws_security_group.rds_security_group.id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # DB subnet group
  subnet_ids = module.vpc.private_subnets

  # DB parameter group
  family = "postgres11"

  # DB option group
  major_engine_version = "11"

  # Snapshot name upon DB deletion
  final_snapshot_identifier = var.db_identifier
}

##################
# Kubernetes
##################
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
  // This ensures the cluster is ready and the config map has already been applied.
  // Without this, kubernetes_service won't be able to auth with the cluster.
  depends_on = [module.eks.config_map_aws_auth]

  metadata {
    name = var.name
  }
  spec {
    selector = {
      app = var.name
    }
    port {
      port = 80
      target_port = 3000
    }
    type = "LoadBalancer"
  }
}


resource "kubernetes_deployment" "deployment" {
  // This ensures the cluster is ready and the config map has already been applied.
  // Without this, kubernetes_service won't be able to auth with the cluster.
  depends_on = [module.eks.config_map_aws_auth]

  metadata {
    name = var.name
    labels = {
      app = var.name
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = var.name
      }
    }
    template {
      metadata {
        labels = {
          app = var.name
        }
      }

      spec {
        container {
          image = var.image
          name = var.name
          port {
            container_port = 3000
          }

          env {
            name = "DATABASE_HOST"
            value = module.rds.this_db_instance_endpoint
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

##################
# Route53
##################
data "aws_route53_zone" "selected" {
  name = var.domain
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.name}.${var.environment}.${data.aws_route53_zone.selected.name}"
  type    = "CNAME"
  ttl     = "300"
  records = [kubernetes_service.service.load_balancer_ingress.0.hostname]
}