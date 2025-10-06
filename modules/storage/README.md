# Storage Module

## Purpose

Provisions and manages S3 buckets for Paperwurks document storage, uploads, and static assets. Handles bucket policies, lifecycle management, versioning, and encryption for secure file storage.

## What This Module Creates

- **Documents Bucket**: Long-term property document storage
- **Uploads Bucket**: Temporary upload staging area
- **Bucket Policies**: Access control and permissions
- **CORS Configuration**: Cross-origin upload support
- **Lifecycle Rules**: Automatic data tiering and archival
- **Versioning**: Protection against accidental deletion
- **Encryption**: AES-256 encryption at rest
- **Public Access Block**: Security hardening

## When To Use

Use this module when you need to:

- Store user-uploaded files (PDFs, images, documents)
- Serve static content (application assets)
- Archive data with compliance requirements
- Implement multi-stage upload workflows
- Store backups or exports

## What This Module Does NOT Do

- Process or transform files (use Lambda for that)
- Generate pre-signed URLs (application handles)
- Scan files for malware (integrate with third-party)
- Manage CDN distribution (use CloudFront separately)
- Index or search documents (use application database)

## Dependencies

**Required Inputs:**

- Environment name (for bucket naming)
- Lifecycle rules configuration
- Versioning preferences
- Encryption settings

**AWS Services Used:**

- Amazon S3 (object storage)
- AWS KMS (optional, for encryption)
- S3 Lifecycle Management
- S3 Replication (optional, for DR)

## Key Decisions This Module Makes

- **Storage Classes**: Standard, IA, Glacier transitions
- **Lifecycle Policies**: When to archive or delete
- **Versioning**: On or off per bucket
- **Access Patterns**: Public vs private vs mixed
- **CORS Rules**: Which origins can upload
- **Retention Policies**: Compliance hold periods

## Cost Implications

**Primary Cost Drivers:**

- Storage volume (per GB per month)
- Request operations (PUT, GET, DELETE)
- Data transfer out to internet
- Lifecycle transitions between storage classes
- Replication (if enabled)

**Typical Monthly Cost Range:**

- Dev: £1-5 (minimal usage, <50GB)
- Staging: £5-15 (testing data, <200GB)
- Production: £50-200 (customer documents, 500GB-2TB)

**Storage Class Pricing:**

- Standard: £0.023/GB/month
- Standard-IA: £0.0125/GB/month (after 90 days)
- Glacier: £0.004/GB/month (after 365 days)

## Security Considerations

**What This Module Protects:**

- All buckets block public access by default
- Encryption at rest for all objects
- HTTPS required for all access
- Bucket policies enforce least privilege
- Versioning protects against deletion
- Access logging tracks all requests

**What You Must Configure:**

- Application IAM role permissions
- Pre-signed URL expiration times
- File upload size limits (application-side)
- Malware scanning integration
- Data classification policies

## Typical Usage Pattern

1. **This module** creates S3 buckets
2. Application gets IAM credentials
3. User initiates file upload in browser
4. Application generates pre-signed URL
5. Browser uploads directly to S3
6. S3 triggers event notification
7. Application processes upload confirmation
8. Lifecycle rules tier data automatically
9. Files archived to Glacier after 365 days

## Integration Points

**Consumes:**

- KMS keys (optional, for encryption)
- IAM roles (for bucket policies)

**Provides:**

- Bucket names (for application configuration)
- Bucket ARNs (for IAM policies)
- Regional endpoints (for SDK configuration)

## Operational Considerations

**Lifecycle Management:**

- Transition to Standard-IA after 90 days (cost savings)
- Transition to Glacier after 365 days (compliance)
- Delete temporary uploads after 7 days
- Enable Intelligent-Tiering for unknown patterns

**Versioning Strategy:**

- Documents bucket: Versioning enabled (audit trail)
- Uploads bucket: Versioning disabled (temporary)
- Version expiration after 90 days (cost control)

**Monitoring Needs:**

- Storage usage growth
- Request metrics (4xx, 5xx errors)
- Replication lag (if enabled)
- Lifecycle rule effectiveness

## Environment Differences

| Aspect          | Dev        | Staging  | Production   |
| --------------- | ---------- | -------- | ------------ |
| **Versioning**  | Disabled   | Enabled  | Enabled      |
| **Lifecycle**   | Aggressive | Moderate | Conservative |
| **Replication** | No         | No       | Optional     |
| **Logging**     | Disabled   | Enabled  | Enabled      |
| **Encryption**  | AES-256    | AES-256  | KMS          |

## Common Modifications

**To reduce costs:**

- Aggressive lifecycle transitions
- Delete old versions sooner
- Disable versioning for non-critical buckets
- Use Intelligent-Tiering
- Optimize request patterns

**To improve compliance:**

- Enable object lock (WORM)
- Longer retention periods
- Cross-region replication
- Access logging enabled
- MFA delete required

**To improve performance:**

- S3 Transfer Acceleration
- CloudFront CDN integration
- Multi-part upload optimization
- Request rate distribution

## Bucket Structure

paperwurks-{env}-documents/
├── properties/
│ ├── {property-id}/
│ │ ├── title-deeds/
│ │ ├── searches/
│ │ └── conveyancing/
└── archive/
paperwurks-{env}-uploads/
├── pending/
│ └── {upload-id}/
└── processing/

## Related Modules

- **compute**: ECS tasks read/write to buckets
- **monitoring**: S3 metrics and alerts
- **networking**: VPC endpoint for S3 (cost optimization)
