# Monitoring Module

## Purpose

Provisions comprehensive observability infrastructure for Paperwurks applications and infrastructure. Centralizes logs, metrics, alarms, and notifications to ensure operational visibility and rapid incident response.

## What This Module Creates

- **CloudWatch Log Groups**: Centralized log aggregation
- **CloudWatch Metrics**: Custom application metrics
- **CloudWatch Alarms**: Automated alerting on thresholds
- **SNS Topics**: Notification routing
- **SNS Subscriptions**: Email and Slack alerts
- **CloudWatch Dashboard**: Visual operational overview
- **Metric Filters**: Log-based metrics extraction
- **Composite Alarms**: Multi-signal alerting

## When To Use

Use this module when you need to:

- Aggregate logs from multiple services
- Alert on application or infrastructure issues
- Track custom business metrics
- Visualize system health
- Comply with logging requirements
- Debug production incidents

## What This Module Does NOT Do

- Analyze log data (use CloudWatch Insights or third-party)
- Store logs long-term (lifecycle manages retention)
- Replace application logging frameworks
- Provide APM/tracing (use X-Ray or third-party)
- Create application-specific metrics (app sends those)

## Dependencies

**Required Inputs:**

- Alert email addresses
- Slack webhook URLs (optional)
- Log retention policies
- Alarm thresholds

**AWS Services Used:**

- Amazon CloudWatch (logs, metrics, alarms, dashboards)
- Amazon SNS (notifications)
- AWS Lambda (optional, for custom alert processing)

## Key Decisions This Module Makes

- **Log Retention**: How long logs are kept
- **Alarm Thresholds**: When to notify
- **Notification Channels**: Who gets alerted
- **Metric Granularity**: Resolution of data points
- **Dashboard Layout**: What to visualize
- **Alarm Actions**: What happens when alarmed

## Cost Implications

**Primary Cost Drivers:**

- Log ingestion volume (per GB)
- Log storage (per GB-month)
- Custom metrics (per metric per month)
- CloudWatch alarms (per alarm)
- Dashboard usage (per dashboard)
- SNS notifications (per notification)

**Typical Monthly Cost Range:**

- Dev: £3-8 (basic logging, few alarms)
- Staging: £8-20 (moderate logs, standard alarms)
- Production: £30-80 (verbose logs, comprehensive alarms)

**Cost Optimization:**

- Aggressive log retention (7-14 days for dev)
- Filter logs before ingestion
- Use metric filters instead of custom metrics
- Consolidated dashboards

## Security Considerations

**What This Module Protects:**

- Logs encrypted at rest
- Access controlled via IAM
- SNS topics encrypted
- Dashboard access restricted
- Audit trail of alarm changes

**What You Must Configure:**

- Log scrubbing for sensitive data
- Access policies for log groups
- Retention policies for compliance
- Encryption keys for sensitive logs

## Typical Usage Pattern

1. **This module** creates log groups and alarms
2. Applications send logs to CloudWatch
3. Metric filters extract patterns
4. Alarms evaluate metrics continuously
5. Threshold breached triggers SNS
6. SNS sends email/Slack notification
7. Engineers investigate via dashboard
8. Logs automatically expire per retention policy

## Integration Points

**Consumes:**

- ECS task logs (compute module)
- ALB access logs (compute module)
- RDS logs (database module)
- Lambda logs (if functions exist)

**Provides:**

- Log group names (for application configuration)
- SNS topic ARNs (for alarm routing)
- Dashboard URLs (for operations team)

## Operational Considerations

**Log Organization:**

- One log group per service
- Consistent naming conventions
- Structured logging (JSON) preferred
- Log levels: DEBUG, INFO, WARN, ERROR

**Alarm Strategy:**

- Critical: Page on-call immediately
- Warning: Email/Slack, review during business hours
- Info: Dashboard only, no notifications
- Composite alarms for complex conditions

**Retention Policy:**

- Dev: 7 days (cost optimization)
- Staging: 14 days (testing needs)
- Production: 30-90 days (compliance/debugging)
- Archive to S3 for longer retention

## Environment Differences

| Aspect                | Dev        | Staging       | Production                |
| --------------------- | ---------- | ------------- | ------------------------- |
| **Log Retention**     | 7 days     | 14 days       | 30 days                   |
| **Alarm Count**       | 5-10       | 10-15         | 20-30                     |
| **Notifications**     | Email only | Email + Slack | Email + Slack + PagerDuty |
| **Dashboard**         | Basic      | Standard      | Comprehensive             |
| **Metric Resolution** | 5 min      | 1 min         | 1 min                     |

## Common Alarms

**Infrastructure:**

- ECS service unhealthy task count
- ALB target health check failures
- RDS CPU utilization high
- NAT Gateway bandwidth exceeded

**Application:**

- HTTP 5xx error rate spike
- Response time p99 > threshold
- Failed login attempts > threshold
- Background job queue depth

**Cost:**

- Daily spend exceeds budget
- Unexpected resource creation

## Dashboard Sections

**System Health:**

- Service status indicators
- Task counts and health
- Load balancer metrics
- Database connections

**Application Performance:**

- Request latency percentiles
- Error rates by endpoint
- Throughput (requests/sec)
- Cache hit ratios

**Business Metrics:**

- Active user count
- Document uploads per hour
- Property transactions initiated
- Search queries executed

## Common Modifications

**To reduce costs:**

- Shorter log retention
- Fewer custom metrics
- Metric filters instead of custom metrics
- Single consolidated dashboard
- Selective log ingestion

**To improve observability:**

- Detailed application metrics
- More granular alarms
- Enhanced dashboard visualizations
- Cross-account log aggregation
- Integration with X-Ray

**To improve alerting:**

- SNS to PagerDuty integration
- Composite alarms for noise reduction
- Alarm escalation policies
- Automated remediation actions
- Runbook links in alarm descriptions

## Alert Routing

Critical Alarms (Production Down)
├── SNS Topic → PagerDuty → On-call Engineer
└── SNS Topic → Slack #incidents
Warning Alarms (Degraded Performance)
├── SNS Topic → Email → DevOps Team
└── SNS Topic → Slack #alerts
Info Alarms (Approaching Limits)
└── SNS Topic → Email → Engineering Lead

## Related Modules

- **compute**: Sends ECS task logs
- **database**: Sends RDS performance logs
- **storage**: Sends S3 access logs
- **networking**: VPC flow logs (optional)

## Related Modules

- **compute**: Sends ECS task logs
- **database**: Sends RDS performance logs
- **storage**: Sends S3 access logs
- **networking**: VPC flow logs (optional)
