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
      "ecr:PutImage"
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

