variable "vpc_id" {
  description = "VPC where the cluster and workers will be deployed."
  type = string
}

variable "cluster_name" {
  description = "Name of EKS cluster for subnet tagging purposes"
  type = string
}

variable "worker_node_subnets" {
  description = "Subnets to launch worker nodes into"
  type = list(string)
  // TODO module.vpc.private_subnets
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)
  default = [
    "777777777777",
    "888888888888",
  ]
}

variable "instance_type" {
  description = ""
  default = "t3.medium"
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = [
    {
      rolearn  = "arn:aws:iam::66666666666:role/role1"
      username = "role1"
      groups   = ["system:masters"]
    },
  ]
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = [
    {
      userarn  = "arn:aws:iam::636934759355:user/carl"
      username = "carl"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::66666666666:user/user2"
      username = "user2"
      groups   = ["system:masters"]
    },
  ]
}