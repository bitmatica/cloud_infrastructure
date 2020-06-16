variable "ecr_repository_name" {
  description = "Name of ECR repository to give github action IAM user access to"
  type = string
}

variable "github_repository_name" {
  description = "Name of github repository"
  type = string
}

variable "aws_region" {
  description = "AWS region of ECR repository"
  type = string
}

variable "terraform_github_repository_name" {
  description = "Name of github repository with terraform infrastructure code"
  type = string
}

variable "terraform_github_repository_org_name" {
  description = "Name of github org with terraform infrastructure code"
  type = string
}

variable "terraform_github_repository_version_path" {
  description = "Path of config file with app version"
  type = string
}