resource "github_actions_secret" "AWS_ACCESS_KEY_ID" {
  repository       = var.github_repository_name
  secret_name      = "AWS_ACCESS_KEY_ID"
  plaintext_value  = aws_iam_access_key.github_actions_access_key.id
}

resource "github_actions_secret" "AWS_SECRET_ACCESS_KEY" {
  repository       = var.github_repository_name
  secret_name      = "AWS_SECRET_ACCESS_KEY"
  plaintext_value  = aws_iam_access_key.github_actions_access_key.secret
}

resource "github_actions_secret" "AWS_REGION" {
  repository       = var.github_repository_name
  secret_name      = "AWS_REGION"
  plaintext_value  = var.aws_region
}

resource "github_actions_secret" "AWS_S3_BUCKET" {
  repository       = var.github_repository_name
  secret_name      = "AWS_S3_BUCKET"
  plaintext_value  = var.s3_bucket_name
}

resource "github_actions_secret" "PUBLIC_URL" {
  repository       = var.github_repository_name
  secret_name      = "PUBLIC_URL"
  plaintext_value  = var.public_url
}

resource "github_actions_secret" "SERVER_URI" {
  repository       = var.github_repository_name
  secret_name      = "SERVER_URI"
  plaintext_value  = var.server_uri
}

resource "aws_iam_user" "github_actions_user" {
  name = "github-actions-${var.github_repository_name}"
}

resource "aws_iam_access_key" "github_actions_access_key" {
  user = aws_iam_user.github_actions_user.name
}

resource "aws_iam_user_policy" "github_actions_policy" {
  name = "S3Write-${var.github_repository_name}"
  user = aws_iam_user.github_actions_user.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::${var.s3_bucket_name}/*"
            ]
        }
    ]
}
EOF
}