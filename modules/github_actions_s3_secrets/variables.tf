variable "s3_bucket_name" {
  description = "Name of s3 bucket to give github action IAM user push access to"
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

variable "public_url" {
  description = "Public URL that frontend bundle will be hosted at, such as the CloudFront CDN URL"
  type = string
}

variable "server_uri" {
  description = "Public URI that backend API will be hosted at"
  type = string
}