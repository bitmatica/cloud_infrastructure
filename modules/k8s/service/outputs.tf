output "hostname" {
  description = "The public hostname of the service"
  value = kubernetes_service.service.load_balancer_ingress.0.hostname
}