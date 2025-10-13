# Application Configuration Module

## Purpose

Manages Django application configuration by provisioning AWS Secrets Manager secrets and SSM Parameter Store entries for environment variables. Separates sensitive credentials from non-sensitive configuration and integrates with ECS task definitions.

## What This Module Creates

- **Secrets Manager Secrets**: Django SECRET_KEY, DATABASE_URL, external API keys
- **SSM Parameters**: Non-sensitive configuration (DEBUG, ALLOWED_HOSTS, CORS, feature flags)
- **Random Passwords**: Django SECRET_KEY generation
- **Configuration Hierarchy**: Organized by category (django/, aws/, features/)

## Configuration Categories

### Secrets Manager (Sensitive Data)

```
/paperwurks/{env}/django:
  - SECRET_KEY: Django cryptographic signing key
  - DATABASE_URL: Complete PostgreSQL connection string

/paperwurks/{env}/external_apis:
  - NLIS_API_KEY: NLIS property data API key
  - GROUNDSURE_API_KEY: Groundsure API key
```

### Parameter Store (Non-Sensitive)

```
/paperwurks/{env}/django/*:
  - ENVIRONMENT: development/staging/production
  - DEBUG: True/False
  - ALLOWED_HOSTS: Comma-separated hostnames
  - CORS_ALLOWED_ORIGINS: Comma-separated frontend URLs
  - CSRF_TRUSTED_ORIGINS: Trusted origins (prod only)
  - LOG_LEVEL: DEBUG/INFO/WARNING/ERROR
  - DJANGO_SETTINGS_MODULE: Settings module path

/paperwurks/{env}/aws/*:
  - REGION: AWS region
  - STORAGE_BUCKET_NAME: S3 documents bucket

/paperwurks/{env}/features/*:
  - ENABLE_AI_ANALYSIS: Feature flag
  - ENABLE_DOCUMENT_PROCESSING: Feature flag
  - ENABLE_SEARCH_INTEGRATION: Feature flag
```

## Environment-Specific Values

### Development

- **DEBUG**: True
- **ALLOWED_HOSTS**: localhost,127.0.0.1,dev-alb-\*.elb.amazonaws.com
- **CORS_ORIGINS**: http://localhost:3000,http://localhost:5173
- **LOG_LEVEL**: DEBUG
- **Security Settings**: Not enforced

### Staging

- **DEBUG**: True
- **ALLOWED_HOSTS**: staging-alb-\*.elb.amazonaws.com,staging.paperwurks.co.uk
- **CORS_ORIGINS**: https://staging.paperwurks.co.uk,https://app-staging.paperwurks.co.uk
- **LOG_LEVEL**: INFO
- **Security Settings**: Not enforced

### Production

- **DEBUG**: False
- **ALLOWED_HOSTS**: alb-\*.elb.amazonaws.com,api.paperwurks.co.uk,paperwurks.co.uk
- **CORS_ORIGINS**: https://paperwurks.co.uk,https://app.paperwurks.co.uk
- **CSRF_TRUSTED_ORIGINS**: https://paperwurks.co.uk,https://app.paperwurks.co.uk,https://api.paperwurks.co.uk
- **LOG_LEVEL**: INFO
- **Security Settings**: SSL redirect, secure cookies, HSTS enabled

## Usage

```hcl
module "app_config" {
  source = "../../modules/app_config"

  project_name          = var.project_name
  environment           = var.environment
  documents_bucket_name = module.storage.documents_bucket_name

  # Feature flags
  enable_ai_analysis          = true
  enable_document_processing  = true
  enable_search_integration   = false

  # External API keys (optional)
  nlis_api_key       = var.nlis_api_key
  groundsure_api_key = var.groundsure_api_key

  depends_on = [
    module.database,
    module.storage
  ]
}
```

## Integration with ECS Tasks

The compute module references these secrets/parameters in task definitions:

```hcl
# In modules/compute/main.tf

secrets = [
  {
    name      = "SECRET_KEY"
    valueFrom = "${module.app_config.django_secret_arn}:SECRET_KEY::"
  },
  {
    name      = "DATABASE_URL"
    valueFrom = "${module.app_config.django_secret_arn}:DATABASE_URL::"
  },
  {
    name      = "REDIS_URL"
    valueFrom = "/paperwurks/${var.environment}/redis/url"
  }
]

environment = [
  {
    name  = "ENVIRONMENT"
    value = var.environment
  },
  {
    name  = "DEBUG"
    value = var.environment == "prod" ? "False" : "True"
  }
]
```

## Dependencies

**Required Inputs:**

- Database module (for existing DB credentials secret)
- Storage module (for S3 bucket names)

**AWS Services Used:**

- AWS Secrets Manager
- AWS Systems Manager Parameter Store
- AWS KMS (for encryption)

## Security Considerations

**What This Module Protects:**

- Sensitive credentials stored in Secrets Manager with encryption
- SecureString parameters for additional security
- 30-day recovery window for production secrets
- Separation of sensitive vs non-sensitive config

**IAM Permissions Required:**

- ECS Task Execution Role needs `secretsmanager:GetSecretValue`
- ECS Task Execution Role needs `ssm:GetParameter`
- ECS Task Role needs runtime access to parameters

## Cost Implications

**Secrets Manager:**

- $0.40 per secret per month
- $0.05 per 10,000 API calls
- Typical cost: £1-2/month per environment

**Parameter Store:**

- Standard parameters: Free
- No API call charges for standard tier

**Total Monthly Cost:** ~£1-2 per environment

## Maintenance

### Rotating Secrets

**Django SECRET_KEY:**

```bash
# Force rotation by tainting the resource
terraform taint module.app_config.random_password.django_secret_key
terraform apply

# Restart ECS tasks to pick up new key
aws ecs update-service --cluster {env}-paperwurks-cluster \
  --service {env}-paperwurks-backend --force-new-deployment
```

**External API Keys:**
Update variables and apply:

```bash
terraform apply -var="nlis_api_key=new-key-here"
```

### Adding New Configuration

1. Add SSM parameter resource in `main.tf`
2. Add output in `outputs.tf`
3. Reference in compute module task definition
4. Update this README

## Troubleshooting

### Secret Not Found

```bash
# Verify secret exists
aws secretsmanager describe-secret \
  --secret-id paperwurks/{env}/django

# Check secret value
aws secretsmanager get-secret-value \
  --secret-id paperwurks/{env}/django
```

### Parameter Not Found

```bash
# List all parameters
aws ssm get-parameters-by-path \
  --path /paperwurks/{env}/ \
  --recursive

# Get specific parameter
aws ssm get-parameter \
  --name /paperwurks/{env}/django/DEBUG
```

### ECS Task Can't Read Secrets

```bash
# Check IAM permissions
aws iam get-role-policy \
  --role-name paperwurks-{env}-ecs-task-execution \
  --policy-name ecs-task-execution-ssm

# Check ECS task logs
aws logs tail /ecs/{env}-paperwurks-backend --follow
```

## Related Modules

- **database**: Provides existing DB credentials secret
- **elasticache**: Provides Redis URL parameter
- **storage**: Provides S3 bucket names
- **compute**: Consumes all configuration in task definitions

## References

- [AWS Secrets Manager Best Practices](https://docs.aws.amazon.com/secretsmanager/latest/userguide/best-practices.html)
- [ECS Secrets](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data.html)
- [Django Settings](https://docs.djangoproject.com/en/5.0/topics/settings/)
- [python-decouple Documentation](https://github.com/HBNetwork/python-decouple)
