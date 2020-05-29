variable "name" {
  description = "Name of app"
  type = string
}

variable "environment" {
  description = "Environment, such as dev"
  type = string
}

locals {
  image = "636934759355.dkr.ecr.us-east-1.amazonaws.com/nest-blogmatica:6983c3d879f8a15530eb78290776655a0d6e4275"
}