variable "name" {
  description = "Name of static site"
  type = string
}

variable "domain_name" {
  description = "Domain name, such as test.bitmatica.com"
  type = string
}

variable "public_hosted_zone_domain_name" {
  description = "Domain name of existing public hosted zone"
  type = string
  default = "bitmatica.com"
}

variable "frontend_version" {
  description = "Version of frontend to serve from default CloudFront root.  This corresponds to bucket object key under main deploy bucket"
  type = string
}