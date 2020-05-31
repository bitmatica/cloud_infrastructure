output "service_host" {
  description = "Host of publicly accessible service"
  value = kubernetes_service.service.load_balancer_ingress.0.hostname
}