provider "aws" {
  region = var.aws_region
}

module "setup" {
  source      = "../../setup"
  project_name = "paperwurks"
  aws_region   = var.aws_region
  environment  = var.environment
}
