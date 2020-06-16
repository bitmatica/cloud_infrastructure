output "dev_frontend_bucket_name" {
  value = local.dev_frontend_bucket_name
}

output "ecr_repository_name" {
  value = aws_ecr_repository.repository.name
}

output "app_name" {
  value = local.app_name
}

output "aws_region" {
  value = local.region
}
