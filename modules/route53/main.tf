data "aws_route53_zone" "selected" {
  name = "bitmatica.com."
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.selected.zone_id
  // TODO "${var.app_name}.${var.app_environment}
  name    = "${var.subdomain}.${data.aws_route53_zone.selected.name}"
  type    = "CNAME"
  ttl     = "300"
  // TODO [kubernetes_service.service.load_balancer_ingress.0.hostname]
  records = [var.hostname]
}