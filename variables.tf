variable "region" {
  default = "us-west-2"
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

variable "cluster_name" {
  default = "blogmatica-dev"
}