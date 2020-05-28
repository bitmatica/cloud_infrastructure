resource "kubernetes_deployment" "deployment" {
  timeouts {}
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
