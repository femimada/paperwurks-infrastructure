# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

# -----------------------------------------------------------------------------
# ECS Cluster
# -----------------------------------------------------------------------------

resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = var.environment == "prod" ? "enabled" : "disabled"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-cluster"
    Environment = var.environment
  }
}

# -----------------------------------------------------------------------------
# CloudWatch Log Groups
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "backend" {
  name              = "/ecs/${var.environment}-${var.project_name}-backend"
  retention_in_days = var.environment == "prod" ? 30 : 7

  tags = {
    Name        = "${var.project_name}-${var.environment}-backend-logs"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "worker" {
  name              = "/ecs/${var.environment}-${var.project_name}-worker"
  retention_in_days = var.environment == "prod" ? 30 : 7

  tags = {
    Name        = "${var.project_name}-${var.environment}-worker-logs"
    Environment = var.environment
  }
}

# -----------------------------------------------------------------------------
# Application Load Balancer
# -----------------------------------------------------------------------------

resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids # FIXED: Was private_subnet_ids

  enable_deletion_protection       = var.environment == "prod" ? true : false
  enable_cross_zone_load_balancing = true
  enable_http2                     = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-alb"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "backend" {
  name                 = "${var.project_name}-${var.environment}-backend-tg"
  port                 = 8000
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "ip" # CHANGED: Required for Fargate awsvpc mode
  deregistration_delay = 30

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/health/"
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-backend-tg"
    Environment = var.environment
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}

resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.environment}-${var.project_name}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.backend_cpu
  memory                   = var.backend_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "paperwurks-backend"
      image     = var.backend_image
      cpu       = var.backend_cpu
      memory    = var.backend_memory
      essential = true

      portMappings = [
        {
          containerPort = 8000
          protocol      = "tcp"
        }
      ]

      # Static environment variables
      environment = [
        {
          name  = "ENVIRONMENT"
          value = var.environment
        },
        {
          name  = "AWS_REGION"
          value = data.aws_region.current.name
        },
        {
          name  = "AWS_DEFAULT_REGION"
          value = data.aws_region.current.name
        }
      ]

      # Secrets from Secrets Manager and Parameter Store
      secrets = concat(
        # Django secrets from Secrets Manager
        [
          {
            name      = "SECRET_KEY"
            valueFrom = "${var.django_secret_arn}:SECRET_KEY::"
          },
          {
            name      = "DATABASE_URL"
            valueFrom = "${var.django_secret_arn}:DATABASE_URL::"
          }
        ],
        # Redis configuration
        var.redis_url_parameter_name != "" ? [
          {
            name      = "REDIS_URL"
            valueFrom = var.redis_url_parameter_name
          },
          {
            name      = "CELERY_BROKER_URL"
            valueFrom = var.redis_url_parameter_name
          },
          {
            name      = "CELERY_RESULT_BACKEND"
            valueFrom = var.redis_url_parameter_name
          }
        ] : [],
        # Django configuration from Parameter Store
        var.django_debug_parameter != "" ? [
          {
            name      = "DEBUG"
            valueFrom = var.django_debug_parameter
          },
          {
            name      = "ALLOWED_HOSTS"
            valueFrom = var.allowed_hosts_parameter
          },
          {
            name      = "CORS_ALLOWED_ORIGINS"
            valueFrom = var.cors_origins_parameter
          },
          {
            name      = "LOG_LEVEL"
            valueFrom = var.log_level_parameter
          },
          {
            name      = "DJANGO_SETTINGS_MODULE"
            valueFrom = var.django_settings_module_parameter
          }
        ] : [],
        # AWS configuration from Parameter Store
        var.storage_bucket_parameter != "" ? [
          {
            name      = "AWS_STORAGE_BUCKET_NAME"
            valueFrom = var.storage_bucket_parameter
          }
        ] : [],
        # Feature flags from Parameter Store
        var.enable_ai_analysis_parameter != "" ? [
          {
            name      = "ENABLE_AI_ANALYSIS"
            valueFrom = var.enable_ai_analysis_parameter
          },
          {
            name      = "ENABLE_DOCUMENT_PROCESSING"
            valueFrom = var.enable_document_processing_parameter
          },
          {
            name      = "ENABLE_SEARCH_INTEGRATION"
            valueFrom = var.enable_search_integration_parameter
          }
        ] : [],
        # Production security settings (only if parameters exist)
        var.csrf_origins_parameter != "" ? [
          {
            name      = "CSRF_TRUSTED_ORIGINS"
            valueFrom = var.csrf_origins_parameter
          },
          {
            name      = "SECURE_SSL_REDIRECT"
            valueFrom = var.secure_ssl_redirect_parameter
          },
          {
            name      = "SESSION_COOKIE_SECURE"
            valueFrom = var.session_cookie_secure_parameter
          },
          {
            name      = "CSRF_COOKIE_SECURE"
            valueFrom = var.csrf_cookie_secure_parameter
          },
          {
            name      = "SECURE_HSTS_SECONDS"
            valueFrom = var.hsts_seconds_parameter
          }
        ] : []
      )

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.backend.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:8000/health/ || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  tags = {
    Name        = "${var.environment}-${var.project_name}-backend"
    Environment = var.environment
  }
}

resource "aws_ecs_task_definition" "worker" {
  family                   = "${var.environment}-${var.project_name}-worker"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.worker_cpu
  memory                   = var.worker_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "celery-worker"
      image     = var.worker_image
      cpu       = var.worker_cpu
      memory    = var.worker_memory
      essential = true

      # Static environment variables
      environment = [
        {
          name  = "ENVIRONMENT"
          value = var.environment
        },
        {
          name  = "AWS_REGION"
          value = data.aws_region.current.name
        },
        {
          name  = "AWS_DEFAULT_REGION"
          value = data.aws_region.current.name
        }
      ]

      # Secrets from Secrets Manager and Parameter Store (same as backend)
      secrets = concat(
        # Django secrets from Secrets Manager
        [
          {
            name      = "SECRET_KEY"
            valueFrom = "${var.django_secret_arn}:SECRET_KEY::"
          },
          {
            name      = "DATABASE_URL"
            valueFrom = "${var.django_secret_arn}:DATABASE_URL::"
          }
        ],
        # Redis configuration
        var.redis_url_parameter_name != "" ? [
          {
            name      = "REDIS_URL"
            valueFrom = var.redis_url_parameter_name
          },
          {
            name      = "CELERY_BROKER_URL"
            valueFrom = var.redis_url_parameter_name
          },
          {
            name      = "CELERY_RESULT_BACKEND"
            valueFrom = var.redis_url_parameter_name
          }
        ] : [],
        # Django configuration from Parameter Store
        var.django_debug_parameter != "" ? [
          {
            name      = "DEBUG"
            valueFrom = var.django_debug_parameter
          },
          {
            name      = "ALLOWED_HOSTS"
            valueFrom = var.allowed_hosts_parameter
          },
          {
            name      = "LOG_LEVEL"
            valueFrom = var.log_level_parameter
          },
          {
            name      = "DJANGO_SETTINGS_MODULE"
            valueFrom = var.django_settings_module_parameter
          }
        ] : [],
        # AWS configuration from Parameter Store
        var.storage_bucket_parameter != "" ? [
          {
            name      = "AWS_STORAGE_BUCKET_NAME"
            valueFrom = var.storage_bucket_parameter
          }
        ] : [],
        # Feature flags from Parameter Store
        var.enable_ai_analysis_parameter != "" ? [
          {
            name      = "ENABLE_AI_ANALYSIS"
            valueFrom = var.enable_ai_analysis_parameter
          },
          {
            name      = "ENABLE_DOCUMENT_PROCESSING"
            valueFrom = var.enable_document_processing_parameter
          },
          {
            name      = "ENABLE_SEARCH_INTEGRATION"
            valueFrom = var.enable_search_integration_parameter
          }
        ] : []
      )

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.worker.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name        = "${var.environment}-${var.project_name}-worker"
    Environment = var.environment
  }
}

# -----------------------------------------------------------------------------
# ECS Services (Fargate)
# -----------------------------------------------------------------------------

resource "aws_ecs_service" "backend" {
  name            = "${var.environment}-${var.project_name}-backend"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = var.backend_desired_count
  launch_type     = "FARGATE" # CHANGED: From capacity provider strategy

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  # ADDED: Network configuration required for Fargate
  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = "paperwurks-backend"
    container_port   = 8000
  }

  depends_on = [aws_lb_listener.http]

  tags = {
    Name        = "${var.environment}-${var.project_name}-backend"
    Environment = var.environment
  }
}

resource "aws_ecs_service" "worker" {
  name            = "${var.environment}-${var.project_name}-worker"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.worker.arn
  desired_count   = var.worker_desired_count
  launch_type     = "FARGATE" # CHANGED: From capacity provider strategy

  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  # ADDED: Network configuration required for Fargate
  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_sg_id]
    assign_public_ip = false
  }

  tags = {
    Name        = "${var.environment}-${var.project_name}-worker"
    Environment = var.environment
  }
}