variable "name" {
  description = "Name of VPC"
  type = string
  default = "test-vpc"
}

variable "cluster_name" {
  description = "Name of EKS cluster for subnet tagging purposes"
  type = string
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