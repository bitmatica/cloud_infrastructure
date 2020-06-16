data "aws_ecr_repository" "repository" {
  name = var.ecr_repository_name
}

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

resource "github_actions_secret" "AWS_ECR_REPOSITORY" {
  repository       = var.github_repository_name
  secret_name      = "AWS_ECR_REPOSITORY"
  plaintext_value  = data.aws_ecr_repository.repository.name
}

resource "github_actions_secret" "AWS_REGION" {
  repository       = var.github_repository_name
  secret_name      = "AWS_REGION"
  plaintext_value  = var.aws_region
}

resource "github_actions_secret" "TERRAFORM_DEPLOY_KEY" {
  repository       = var.github_repository_name
  secret_name      = "TERRAFORM_DEPLOY_KEY"
  plaintext_value  = tls_private_key.ssh_key.private_key_pem
}

resource "github_actions_secret" "TERRAFORM_REPO_NAME" {
  repository       = var.github_repository_name
  secret_name      = "TERRAFORM_REPO_NAME"
  plaintext_value  = var.terraform_github_repository_name
}

resource "github_actions_secret" "TERRAFORM_REPO_ORG" {
  repository       = var.github_repository_name
  secret_name      = "TERRAFORM_REPO_ORG"
  plaintext_value  = var.terraform_github_repository_org_name
}

resource "github_actions_secret" "TERRAFORM_REPO_VERSION_PATH" {
  repository       = var.github_repository_name
  secret_name      = "TERRAFORM_REPO_VERSION_PATH"
  plaintext_value  = var.terraform_github_repository_version_path
}

resource "aws_iam_user" "github_actions_user" {
  name = "github-actions-${var.github_repository_name}"
}

resource "aws_iam_access_key" "github_actions_access_key" {
  user = aws_iam_user.github_actions_user.name
}

resource "aws_iam_user_policy" "github_actions_policy" {
  name = "ECRReadWrite-${var.github_repository_name}"
  user = aws_iam_user.github_actions_user.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "GetAuthorizationToken",
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowPush",
            "Effect": "Allow",
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload"
            ],
            "Resource": "${data.aws_ecr_repository.repository.arn}"
        }
    ]
}
EOF
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "github_repository_deploy_key" "deploy_key" {
  key =        tls_private_key.ssh_key.public_key_openssh
  repository = var.terraform_github_repository_name
  title =      "github actions deploy key for updating ECR image"
  read_only = "false"
}