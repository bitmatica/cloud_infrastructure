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