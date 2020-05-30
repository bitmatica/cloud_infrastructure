variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
}

variable "cidr" {
  description = "CIDR block for VPC"
  type = string
  default = "192.168.0.0/16"
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type = list(string)
  default = ["192.168.0.0/18", "192.168.64.0/18"]
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type = list(string)
  default = ["192.168.128.0/18", "192.168.192.0/18"]
}

variable "cluster_name" {
  description = "Name of the EKS cluster to be used in VPC.  Used for tagging public/private subnets"
  type        = string
}
