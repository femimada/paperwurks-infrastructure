# Database Module

## Purpose

Provisions and manages a highly available, secure PostgreSQL database for Paperwurks application data persistence. Handles database configuration, backups, monitoring, and credential management.

## What This Module Creates

- **RDS PostgreSQL Instance**: Managed database server
- **DB Subnet Group**: Network isolation for database
- **DB Parameter Group**: PostgreSQL configuration tuning
- **Secrets Manager Secret**: Secure credential storage
- **CloudWatch Log Exports**: Database activity logs
- **Automated Backups**: Point-in-time recovery capability
- **IAM Roles**: Enhanced monitoring permissions (if enabled)

## When To Use

Use this module when you need to:

- Store relational application data
- Require ACID transaction guarantees
- Need automated backup and recovery
- Want managed database maintenance
- Require encryption at rest and in transit

## What This Module Does NOT Do

- Initialize database schema (application responsibility)
- Manage database migrations (application/CI/CD handles)
- Create application database users
- Configure application connection pooling
- Store file/binary data (use S3 instead)

## Dependencies

**Required Inputs:**

- Database subnet IDs (from networking module)
- Security group ID (from networking module)
- Database credentials (username, generated password)

**AWS Services Used:**

- Amazon RDS (PostgreSQL)
- AWS Secrets Manager (credential storage)
- Amazon CloudWatch (monitoring)
- AWS Backup (optional enhanced backups)

## Key Decisions This Module Makes

- **Engine Version**: PostgreSQL version selection
- **Instance Sizing**: Compute and memory allocation
- **Storage Type**: gp3 vs io1 vs io2
- **Multi-AZ**: High availability vs cost
- **Backup Retention**: Recovery point objective (RPO)
- **Maintenance Window**: When updates occur

## Cost Implications

**Primary Cost Drivers:**

- Database instance hours (24/7 operation)
- Storage allocation and IOPS
- Multi-AZ deployment (doubles compute cost)
- Backup storage beyond free tier
- Enhanced monitoring (if enabled)

**Typical Monthly Cost Range:**

- Dev: £25-35 (db.t3.small, single-AZ, 20GB)
- Staging: £30-45 (db.t3.small, single-AZ, 20GB)
- Production: £100-150 (db.t3.medium, Multi-AZ, 100GB)

## Security Considerations

**What This Module Protects:**

- Database runs in isolated subnet (no internet access)
- Encryption at rest using AWS KMS
- Encryption in transit using SSL/TLS
- Master password stored in Secrets Manager
- IAM database authentication supported
- Security group limits access to application only

**What You Must Configure:**

- Application database users and permissions
- SSL certificate validation in application
- Secrets Manager rotation policy
- Network access patterns

## Typical Usage Pattern

1. Networking module creates database subnets
2. **This module** creates RDS instance
3. Module generates secure password
4. Password stored in Secrets Manager
5. Application reads credentials from Secrets Manager
6. Application connects to database endpoint
7. Automated backups run daily
8. CloudWatch monitors database metrics

## Integration Points

**Consumes:**

- VPC configuration (networking module)
- Database security group (networking module)
- KMS key (optional, for encryption)

**Provides:**

- Database endpoint (connection string)
- Secrets Manager ARN (for credentials)
- Database name
- Port number

## Operational Considerations

**Backup Strategy:**

- Automated daily backups during maintenance window
- Retention: 7 days (dev/staging), 30 days (production)
- Manual snapshots before major changes
- Point-in-time recovery available

**Maintenance Windows:**

- Prefer low-traffic periods
- OS updates applied automatically
- PostgreSQL minor version updates (configurable)
- Notifications sent before maintenance

**Performance Monitoring:**

- CPU utilization
- Database connections
- Disk I/O
- Replication lag (Multi-AZ)

## Environment Differences

| Aspect                  | Dev         | Staging     | Production   |
| ----------------------- | ----------- | ----------- | ------------ |
| **Instance Class**      | db.t3.small | db.t3.small | db.t3.medium |
| **Multi-AZ**            | No          | No          | Yes          |
| **Storage**             | 20GB        | 20GB        | 100GB        |
| **Backup Retention**    | 7 days      | 7 days      | 30 days      |
| **Deletion Protection** | No          | No          | Yes          |

## Common Modifications

**To reduce costs:**

- Use smaller instance classes
- Disable Multi-AZ for non-production
- Reduce allocated storage
- Shorter backup retention
- Disable enhanced monitoring

**To improve reliability:**

- Enable Multi-AZ deployment
- Increase storage allocation
- Enable automated minor version upgrades
- More frequent backup windows
- Enable deletion protection

**To improve performance:**

- Larger instance classes
- Provisioned IOPS (io1/io2 storage)
- Read replicas for query offloading
- Connection pooling (application-side)
- Parameter tuning for workload

## Related Modules

- **networking**: Provides database subnets and security
- **compute**: Applications connect from ECS tasks
- **monitoring**: Database metrics and alarms
