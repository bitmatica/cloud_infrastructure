data "aws_route53_zone" "selected" {
  name = "bitmatica.com."
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.subdomain}.${data.aws_route53_zone.selected.name}"
  type    = "CNAME"
  ttl     = "300"
  records = [var.hostname]
}