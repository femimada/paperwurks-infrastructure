# -----------------------------------------------------------------------------
# Configuration Blocks
# -----------------------------------------------------------------------------
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      CostCenter  = var.cost_center
      Team        = var.team
    }
  }
}

locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# -----------------------------------------------------------------------------
# Core Infrastructure Modules
# -----------------------------------------------------------------------------

# Networking Module
module "networking" {
  source = "../../modules/networking"
  
  project_name       = var.project_name
  environment        = var.environment
  aws_region         = var.aws_region
  vpc_cidr          = var.vpc_cidr
  availability_zones = var.availability_zones
  # Conditional logic: 1 NAT GW for dev/staging, 2 for prod
  nat_gateway_count  = var.environment == "prod" ? 2 : 1 
}

# # ECS Cluster and Services
# module "compute" {
#   source = "../../modules/compute"
  
#   project_name        = var.project_name
#   environment         = var.environment
#   vpc_id             = module.networking.vpc_id
#   private_subnet_ids = module.networking.private_subnet_ids
#   alb_sg_id          = module.networking.alb_security_group_id
#   ecs_sg_id          = module.networking.ecs_security_group_id
#   ecs_instance_type       = var.ecs_instance_type
#   ecs_min_size           = var.ecs_min_size
#   ecs_max_size           = var.ecs_max_size
#   ecs_desired_capacity   = var.ecs_desired_capacity
# }

# # RDS Database
# module "database" {
#   source = "../../modules/database"
  
#   project_name         = var.project_name
#   environment          = var.environment
#   database_subnet_ids  = module.networking.database_subnet_ids
#   rds_security_group_id = module.networking.rds_security_group_id
#   db_instance_class    = var.db_instance_class
#   db_allocated_storage = var.db_allocated_storage
#   db_name             = var.db_name
#   db_username         = var.db_username
#   multi_az            = var.environment == "prod" ? true : false 
#   backup_retention    = var.environment == "prod" ? 30 : 7
# }

# # S3 Buckets
# module "storage" {
#   source = "../../modules/storage"
  
#   project_name = var.project_name
#   environment  = var.environment
#   enable_versioning = true
#   enable_encryption = true
#   lifecycle_rules   = var.s3_lifecycle_rules
# }

# # Monitoring
# module "monitoring" {
#   source = "../../modules/monitoring"
  
#   project_name = var.project_name
#   environment  = var.environment
#   alert_email = var.alert_email
#   slack_webhook_url = var.slack_webhook_url
# }


# -----------------------------------------------------------------------------
# IAM SCOPING: Grant Deploy Role access to Dev ECS Resources
# -----------------------------------------------------------------------------

data "aws_iam_role" "deploy_role" {
  name = "${var.project_name}-deploy-role" 
}
data "aws_iam_policy_document" "dev_ecs_deploy" {
  statement {
    effect = "Allow"
    actions = [
      "ecs:DescribeServices",
      "ecs:UpdateService",
      "ecs:DescribeTaskDefinition"
    ]
    resources = [
      module.compute.ecs_cluster_arn,
      module.compute.ecs_service_arn_backend,
      module.compute.ecs_service_arn_worker, 
    ]
  }

  statement {
    effect = "Allow"
    actions = ["iam:PassRole"]
    resources = [
      module.compute.task_execution_role_arn
    ]
    # Enforce that the role can only be passed to the ECS service
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ecs.amazonaws.com"]
    }
  }
}
resource "aws_iam_policy" "dev_ecs_deploy_policy" {
  name        = "${var.project_name}-${var.environment}-ecs-deploy-policy"
  description = "Allows CI/CD to deploy to the ${var.environment} ECS service."
  policy      = data.aws_iam_policy_document.dev_ecs_deploy.json
}
resource "aws_iam_role_policy_attachment" "deploy_role_dev_ecs" {
  role       = data.aws_iam_role.deploy_role.name
  policy_arn = aws_iam_policy.dev_ecs_deploy_policy.arn
}