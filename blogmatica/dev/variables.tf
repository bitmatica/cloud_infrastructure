variable "name" {
  description = "Name of the app"
  type = string
}

variable "environment" {
  description = "Environment of the app, such as dev"
  type = string
}

variable "region" {
  description = "AWS region"
  type        = string
}