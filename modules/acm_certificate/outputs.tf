output "acm_certificate_arn" {
  description = "ARN of created ACM certificate"
  value       = aws_acm_certificate.cert.arn
}
