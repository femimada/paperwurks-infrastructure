#######################################
# Role 1: Terraform Infra Role (infra repo only)
#######################################

resource "aws_iam_role" "terraform_role" {
  name = "${var.project_name}-terraform-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            # infra repo only
            "token.actions.githubusercontent.com:sub" = [
              "repo:my-org/infra-repo:ref:refs/heads/main",
              "repo:my-org/infra-repo:ref:refs/heads/staging"
            ]
          }
        }
      }
    ]
  })
}



# Attach infrastructure policies
resource "aws_iam_role_policy_attachment" "tf_backend" {
  role       = aws_iam_role.terraform_role.name
  policy_arn = aws_iam_policy.tf_backend.arn
}

# EC2 Policy
resource "aws_iam_role_policy_attachment" "ec2" {
  role       = aws_iam_role.terraform_role.name
  policy_arn = aws_iam_policy.ec2.arn
}

# RDS Policy
resource "aws_iam_role_policy_attachment" "rds" {
  role       = aws_iam_role.terraform_role.name
  policy_arn = aws_iam_policy.rds.arn
}

# ECS Policy
resource "aws_iam_role_policy_attachment" "ecs" {
  role       = aws_iam_role.terraform_role.name
  policy_arn = aws_iam_policy.ecs.arn
}

# IAM Policy
resource "aws_iam_role_policy_attachment" "iam" {
  role       = aws_iam_role.terraform_role.name
  policy_arn = aws_iam_policy.iam.arn
}

# CloudWatch Logs
resource "aws_iam_role_policy_attachment" "logs" {
  role       = aws_iam_role.terraform_role.name
  policy_arn = aws_iam_policy.logs.arn
}

#######################################
# Role 2: Deploy Role For the app repo
#######################################

resource "aws_iam_role" "deploy_role" {
  name = "${var.project_name}-deploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringLike = {
          "token.actions.githubusercontent.com:sub" = [
            "repo:my-org/app-repo:ref:refs/heads/main",
            "repo:my-org/app-repo:ref:refs/heads/staging"
          ]
        }
      }
    }]
  })
}

# ECR + ECS only
resource "aws_iam_role_policy_attachment" "ecr" {
  role       = aws_iam_role.deploy_role.name
  policy_arn = aws_iam_policy.ecr.arn
}

resource "aws_iam_role_policy_attachment" "ecs" {
  role       = aws_iam_role.deploy_role.name
  policy_arn = aws_iam_policy.ecs.arn
}
