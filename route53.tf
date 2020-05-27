resource "aws_route53_record" "www" {
  zone_id = var.route_53_zone_id
  name    = "${var.app_name}.${var.app_environment}.bitmatica.com"
  type    = "CNAME"
  ttl     = "300"
  records = [kubernetes_service.service.load_balancer_ingress.0.hostname]
}