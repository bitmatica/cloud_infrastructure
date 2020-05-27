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
            value = module.db.this_db_instance_address
          }
          env {
            name = "DATABASE_PORT"
            value = module.db.this_db_instance_port
          }
          env {
            name = "DATABASE_USER"
            value = module.db.this_db_instance_username
          }
          env {
            name = "DATABASE_PASS"
            value = module.db.this_db_instance_password
          }
          env {
            name = "DATABASE_DB"
            value = module.db.this_db_instance_name
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
