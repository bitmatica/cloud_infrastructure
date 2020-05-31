resource "kubernetes_service" "service" {
  # This is a hack to ensure the cluster is ready and auth has been applied before initial apply
  # Can be removed when Terraform adds support for module's `depends_on`https://github.com/hashicorp/terraform/issues/10462
  depends_on = [var.creation_depends_on]

  # BEGIN SERVICE CONFIG
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
  # This is a hack to ensure the cluster is ready and auth has been applied before initial apply
  # Can be removed when Terraform adds support for module's `depends_on`https://github.com/hashicorp/terraform/issues/10462
  depends_on = [var.creation_depends_on]

  # BEGIN DEPLOYMENT CONFIG
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