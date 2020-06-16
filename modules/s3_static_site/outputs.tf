output "hostname" {
  description = "Hostname that CloudFront points to"
  value = var.domain_name
}

output "s3_bucket_name" {
  description = "Name of s3 bucket that CloudFront points to"
  value = data.aws_s3_bucket.bucket.id
}