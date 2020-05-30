data "aws_eks_cluster" "cluster" {
  name = var.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.11.1"
}

resource "kubernetes_service" "service" {
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
            value = var.db_host
          }
          env {
            name = "DATABASE_PORT"
            value = var.db_port
          }
          env {
            name = "DATABASE_USER"
            value = var.db_username
          }
          env {
            name = "DATABASE_PASS"
            value = var.db_password
          }
          env {
            name = "DATABASE_DB"
            value = var.db_name
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
