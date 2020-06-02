variable "region" {
  description = "AWS region"
  type        = string
}

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
  default = [
    "777777777777",
    "888888888888",
  ]
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
      userarn  = "arn:aws:iam::555555555555:user/user1"
      username = "user1"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::66666666666:user/user2"
      username = "user2"
      groups   = ["system:masters"]
    },
  ]
}
