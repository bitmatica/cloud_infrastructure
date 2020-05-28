variable "region" {
  default = "us-west-2"
}

variable "app_name" {
  description = "Name of app"
  type = string
  default = "blogmatica"
}

variable "environment" {
  description = "Environment, such as dev"
  type = string
  default = "dev"
}

variable "app_image" {
  description = "Image to schedule on k8s pods"
  type = string
  default = "636934759355.dkr.ecr.us-east-1.amazonaws.com/nest-blogmatica:6983c3d879f8a15530eb78290776655a0d6e4275"
}
