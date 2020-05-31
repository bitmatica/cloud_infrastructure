variable "domain" {
  description = "Domain of already existing public hosted zone in route53"
  type = string
  default = "bitmatica.com."
}

variable "subdomain" {
  description = "Subdomain to add to domain"
  type = string
}

variable "hostname" {
  description = "Host to point subdomain at"
  type = string
}