# ECR repo for Django backend
resource "aws_ecr_repository" "paperwurks_backend" {
  name = "paperwurks-backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

# ECR repo for worker jobs (Celery, etc.)
resource "aws_ecr_repository" "celery_worker" {
  name = "celery-worker"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

# ECR repo for Nginx reverse proxy
resource "aws_ecr_repository" "nginx_proxy" {
  name = "nginx-proxy"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}