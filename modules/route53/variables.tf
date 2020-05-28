variable "domain" {
  description = "Domain already im public hosted zone.  A record set will be created to resolve subdomain.domain to hostname"
  type = string
  default = "bitmatica.com."
}

variable "subdomain" {
  description = "Subdomain of domain.  A record set will be created to resolve subdomain.domain to hostname"
  type = string
}

variable "hostname" {
  description = "The domain name that you want to resolve to instead of subdomain.domain"
  // TODO [kubernetes_service.service.load_balancer_ingress.0.hostname]
  type = string
}