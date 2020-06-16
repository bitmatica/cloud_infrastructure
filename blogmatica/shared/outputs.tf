output "ecr_repository_name" {
  value = aws_ecr_repository.repository.name
}

output "app_name" {
  value = local.app_name
}

output "aws_region" {
  value = local.region
}

output "github_secrets_name" {
  value = local.github_secrets_name
}

output "dev_frontend_bucket_name" {
  value = local.dev_frontend_bucket_name
}

output "dev_secrets_name" {
  value = local.dev_secrets_name
}

output "staging_frontend_bucket_name" {
  value = local.staging_frontend_bucket_name
}

output "staging_secrets_name" {
  value = local.staging_secrets_name
}