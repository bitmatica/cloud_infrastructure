variable "cluster_name" {
  description = "Name of the EKS cluster to be used in VPC.  Used for tagging public/private subnets"
  type        = string
}

variable "vpc_id" {
  description = "ID of VPC that EKS cluster will be created in"
  type = string
}

variable "worker_node_subnet_ids" {
  description = "A list of subnets to launch worker nodes into"
  type = list(string)
}

variable "instance_type" {
  description = "Node instance type"
  type = string
  default = "t3.medium"
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)
  default = []
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}
