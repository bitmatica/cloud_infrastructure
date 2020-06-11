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