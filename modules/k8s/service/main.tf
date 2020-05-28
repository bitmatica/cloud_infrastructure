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