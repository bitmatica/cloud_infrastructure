locals {
  backend_image = file("${path.module}/backend_version.txt")
  frontend_version = file("${path.module}/frontend_version.txt")
}