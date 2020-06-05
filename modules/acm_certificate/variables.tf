variable "domain_name" {
  description = "Domain name, such as test.bitmatica.com"
  type = string
}

variable "public_hosted_zone_domain_name" {
  description = "Domain name of existing public hosted zone"
  type = string
  default = "bitmatica.com."
}