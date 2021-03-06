resource "kubernetes_service" "service" {
  # This is a hack to ensure the cluster is ready and auth has been applied before initial apply
  # Can be removed when Terraform adds support for module's `depends_on`https://github.com/hashicorp/terraform/issues/10462
  depends_on = [var.creation_depends_on]

  # BEGIN SERVICE CONFIG
  metadata {
    name = var.name
    annotations = {
      # Note that the backend talks over HTTP.
      "service.beta.kubernetes.io/aws-load-balancer-backend-protocol": "http"
      "service.beta.kubernetes.io/aws-load-balancer-ssl-cert": var.acm_certificate_arn
      # Only run SSL on the port named "https" below.
      "service.beta.kubernetes.io/aws-load-balancer-ssl-ports": "https"
    }
  }
  spec {
    selector = {
      app = var.name
    }
    port {
      name = "https"
      port = 443
      target_port = 3000
    }
    type = "LoadBalancer"
  }
}

resource "kubernetes_secret" "secret" {
  # This is a hack to ensure the cluster is ready and auth has been applied before initial apply
  # Can be removed when Terraform adds support for module's `depends_on`https://github.com/hashicorp/terraform/issues/10462
  depends_on = [var.creation_depends_on]

  metadata {
    name = "${var.name}-secrets"
  }

  data = {
    DATABASE_HOST = var.db_host
    DATABASE_PORT = var.db_port
    DATABASE_USER = var.db_username
    DATABASE_PASS = var.db_password
    DATABASE_DB = var.db_name
    DATABASE_MIGRATIONS = "true"
    KMS_KEY_ARN = aws_kms_key.kms_key.arn
    PLAID_CLIENT_ID = var.plaid_client_id
    PLAID_SECRET = var.plaid_secret
    PLAID_PUBLIC_KEY = var.plaid_public_key
    PLAID_ENV = var.plaid_env
  }
}

resource "kubernetes_deployment" "deployment" {
  # This is a hack to ensure the cluster is ready and auth has been applied before initial apply
  # Can be removed when Terraform adds support for module's `depends_on`https://github.com/hashicorp/terraform/issues/10462
  depends_on = [var.creation_depends_on]

  timeouts {
    create = "5m"
  }

  # BEGIN DEPLOYMENT CONFIG
  metadata {
    name = var.name
    labels = {
      app = var.name
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = var.name
      }
    }
    template {
      metadata {
        labels = {
          app = var.name
        }
      }

      spec {
        service_account_name = local.k8s_service_account_name
        automount_service_account_token = true
        container {
          image = var.image
          name = var.name
          port {
            container_port = 3000
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.secret.metadata[0].name
            }
          }
          image_pull_policy = "Always"
        }
      }
    }
  }
}

resource "aws_kms_key" "kms_key" {
  description = "KMS key used to generate, encrypt and decrypt data keys"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper = false
}

module "iam_assumable_role_admin" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v2.6.0"
  create_role                   = true
  role_name                     = "cluster-kms-${random_string.suffix.result}"
  provider_url                  = replace(var.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.cluster_kms.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.k8s_service_account_namespace}:${local.k8s_service_account_name}"]
}

resource "aws_iam_policy" "cluster_kms" {
  name_prefix = "cluster-kms"
  description = "EKS cluster-kms policy for ${var.name}"
  policy = data.aws_iam_policy_document.cluster_kms.json
}

data "aws_iam_policy_document" "cluster_kms" {
  statement {
    sid    = "KMSClusterEncryptDecrypt"
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = [aws_kms_key.kms_key.arn]
  }
}

resource "kubernetes_service_account" "app_service_account" {
  metadata {
    annotations = {
      "eks.amazonaws.com/role-arn": module.iam_assumable_role_admin.this_iam_role_arn
    }
    name = local.k8s_service_account_name
    namespace = local.k8s_service_account_namespace
  }
}