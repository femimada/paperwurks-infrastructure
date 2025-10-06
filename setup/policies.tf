##################################################
# Terraform Backend Policy (S3 + DynamoDB)
##################################################

data "aws_iam_policy_document" "tf_backend" {
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.terraform_state.arn]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.terraform_state.arn}/*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["dynamodb:DescribeTable", "dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"]
    resources = [aws_dynamodb_table.terraform_state_lock.arn]
  }
}

resource "aws_iam_policy" "tf_backend" {
  name        = "tf-backend-access"
  description = "Access to Terraform S3 backend and DynamoDB lock table"
  policy      = data.aws_iam_policy_document.tf_backend.json
}

##################################################
# ECR Policy
##################################################

data "aws_iam_policy_document" "ecr" {
  statement {
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:CompleteLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:InitiateLayerUpload",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:ListImages"
      "ecr:PutImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:ListImages"
    ]
    resources = [
      aws_ecr_repository.paperwurks_backend.arn,
      aws_ecr_repository.celery_worker.arn,
      aws_ecr_repository.nginx_proxy.arn
    ]
  }
}

resource "aws_iam_policy" "ecr" {
  name        = "ecr-access"
  description = "Allow role to manage ECR resources"
  policy      = data.aws_iam_policy_document.ecr.json
}


data "aws_iam_policy_document" "infra_management" {
  # VPC & Networking
  statement {
    effect = "Allow"
    actions = [
      "ec2:*",
      "elasticloadbalancing:*"
    ]
    resources = ["*"]
  }

  # ECS
  statement {
    effect = "Allow"
    actions = [
      "ecs:*",
      "autoscaling:*"
    ]
    resources = ["*"]
  }

  # RDS
  statement {
    effect    = "Allow"
    actions   = ["rds:*"]
    resources = ["*"]
  }

  # S3 (beyond terraform state)
  statement {
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = ["*"]
  }

  # IAM (for creating service roles)
  statement {
    effect = "Allow"
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:GetRole",
      "iam:PassRole",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:GetRolePolicy",
      "iam:CreatePolicy",
      "iam:DeletePolicy",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListPolicyVersions",
      "iam:CreatePolicyVersion",
      "iam:DeletePolicyVersion",
      "iam:ListAttachedRolePolicies",
      "iam:ListRolePolicies",
      "iam:TagRole",
      "iam:UntagRole"
    ]
    resources = ["*"]
  }

  # Secrets Manager
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:*"]
    resources = ["*"]
  }

  # KMS
  statement {
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]
  }

  # CloudWatch Logs
  statement {
    effect    = "Allow"
    actions   = ["logs:*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "infra_management" {
  name        = "infra-management-policy"
  description = "Full infrastructure management permissions for Terraform"
  policy      = data.aws_iam_policy_document.infra_management.json
}