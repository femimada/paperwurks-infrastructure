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
          StringLike = {
            # infra repo only
            "token.actions.githubusercontent.com:sub" = [
              "repo:femimada/paperwurks-infrastructure:ref:refs/heads/main",
              "repo:femimada/paperwurks-infrastructure:ref:refs/heads/staging"
            ]
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
        StringLike = {
          "token.actions.githubusercontent.com:sub" = [
            "repo:femimada/paperwurks-python-backend:ref:refs/heads/main",
            "repo:femimada/paperwurks-python-backend:ref:refs/heads/staging"
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
