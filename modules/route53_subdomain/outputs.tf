output "hostname" {
  description = "Hostname of created route53 record"
  value = "${var.subdomain}.${var.domain}"
}