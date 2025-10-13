#######################################
# Role 1: Terraform Infra Role (infra repo only)
#######################################

resource "aws_iam_role" "infra_role" {
  name                  = "${var.project_name}-terraform-role"
  force_detach_policies = true

  tags = {
    Project     = "Paperwurks"
    ManagedBy   = "Terraform"
    Environment = "shared"
    RoleType    = "Infra"
  }
  lifecycle {
    ignore_changes = [tags_all]
  }

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
          StringEquals = {
            "token.actions.githubusercontent.com:sub" = "repo:femimada/paperwurks-infrastructure:ref:refs/heads/main"

          }
        }
      }
    ]
  })
}

# Attach infrastructure policies (namespaced)
resource "aws_iam_role_policy_attachment" "infra_tf_backend" {
  role       = aws_iam_role.infra_role.name
  policy_arn = aws_iam_policy.tf_backend.arn
}

resource "aws_iam_role_policy_attachment" "infra_management" {
  role       = aws_iam_role.infra_role.name
  policy_arn = aws_iam_policy.infra_management.arn
}

resource "aws_iam_role_policy_attachment" "infra_cost_explorer" {
  role       = aws_iam_role.infra_role.name
  policy_arn = aws_iam_policy.cost_explorer.arn
}

#######################################
# Role 2: Deploy Role (app repo only)
#######################################

resource "aws_iam_role" "deploy_role" {
  name                  = "${var.project_name}-deploy-role"
  force_detach_policies = true

  tags = {
    Project     = "Paperwurks"
    ManagedBy   = "Terraform"
    Environment = "shared"
    RoleType    = "Deploy"
  }
  lifecycle {
    ignore_changes = [tags_all]
  }

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = [
            "repo:femimada/paperwurks-python-backend:environment:dev",
            "repo:femimada/paperwurks-python-backend:environment:staging",
            "repo:femimada/paperwurks-python-backend:environment:prod",
          ]
        }
      }
    }]
  })
}

# Attach deployment-specific policies
resource "aws_iam_role_policy_attachment" "deploy_ecr" {
  role       = aws_iam_role.deploy_role.name
  policy_arn = aws_iam_policy.ecr.arn
}

resource "aws_iam_role_policy_attachment" "deploy_ecs" {
  role       = aws_iam_role.deploy_role.name
  policy_arn = aws_iam_policy.ecs_deploy.arn
}



