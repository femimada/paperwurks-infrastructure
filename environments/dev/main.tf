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
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  nat_gateway_count  = 1 # Single NAT for dev
}

# ECS Fargate Cluster and Services
module "compute" {
  source = "../../modules/compute"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  public_subnet_ids  = module.networking.public_subnet_ids
  alb_sg_id          = module.networking.alb_security_group_id
  ecs_sg_id          = module.networking.ecs_security_group_id

  # Fargate task sizing
  backend_cpu            = var.backend_cpu
  backend_memory         = var.backend_memory
  worker_cpu             = var.worker_cpu
  worker_memory          = var.worker_memory
  backend_desired_count  = var.backend_desired_count
  worker_desired_count   = var.worker_desired_count

  # Container images (will be updated by CI/CD)
  backend_image = var.backend_image
  worker_image  = var.worker_image
}

# RDS Database
module "database" {
  source = "../../modules/database"

  project_name          = var.project_name
  environment           = var.environment
  database_subnet_ids   = module.networking.database_subnet_ids
  rds_security_group_id = module.networking.rds_security_group_id
  db_instance_class     = var.db_instance_class
  db_allocated_storage  = var.db_allocated_storage
  db_name               = var.db_name
  db_username           = var.db_username
  multi_az              = false # Single-AZ for dev
  backup_retention      = 7     # 7 days for dev
}

# S3 Storage
module "storage" {
  source = "../../modules/storage"

  project_name      = var.project_name
  environment       = var.environment
  enable_versioning = var.enable_versioning
  enable_encryption = true
}

# Monitoring
module "monitoring" {
  source = "../../modules/monitoring"

  project_name = var.project_name
  environment  = var.environment
  alert_email  = var.alert_email
}