
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.environment}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      # ECS Service Health
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            [
              "AWS/ECS",
              "CPUUtilization",
              {
                stat = "Average"
              }
            ],
            [
              ".",
              "MemoryUtilization",
              {
                stat = "Average"
              }
            ]
          ]
          period = 300
          stat   = "Average"
          region = data.aws_region.current.name
          title  = "ECS Cluster Utilization"
          yAxis = {
            left = {
              label = "Percent"
              min   = 0
              max   = 100
            }
          }
        }
      },
      # ALB Metrics
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            [
              "AWS/ApplicationELB",
              "TargetResponseTime",
              {
                stat = "Average"
              }
            ],
            [
              ".",
              "RequestCount",
              {
                stat  = "Sum",
                yAxis = "right"
              }
            ],
            [
              ".",
              "HTTPCode_Target_5XX_Count",
              {
                stat  = "Sum"
                color = "#FF0000"
                yAxis = "right"
              }
            ]
          ]
          period = 300
          region = data.aws_region.current.name
          title  = "Load Balancer Performance"
          yAxis = {
            left = {
              label = "Response Time (seconds)"
            }
            right = {
              label = "Count"
            }
          }
        }
      },
      # RDS Metrics
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            [
              "AWS/RDS",
              "CPUUtilization",
              {
                stat = "Average"
              }
            ],
            [
              ".",
              "DatabaseConnections",
              {
                stat  = "Average"
                yAxis = "right"
              }
            ],
            [
              ".",
              "FreeableMemory",
              {
                stat  = "Average"
                yAxis = "right"
              }
            ]
          ]
          period = 300
          region = data.aws_region.current.name
          title  = "Database Performance"
          yAxis = {
            left = {
              label = "CPU Percent"
              min   = 0
              max   = 100
            }
            right = {
              label = "Connections / Memory"
            }
          }
        }
      },
      # S3 Storage
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            [
              "AWS/S3",
              "BucketSizeBytes",
              {
                stat        = "Average"
                period      = 86400
                StorageType = "StandardStorage"
              }
            ],
            [
              ".",
              "NumberOfObjects",
              {
                stat   = "Average"
                period = 86400
                yAxis  = "right"
              }
            ]
          ]
          period = 86400
          region = data.aws_region.current.name
          title  = "S3 Storage Metrics"
          yAxis = {
            left = {
              label = "Size (Bytes)"
            }
            right = {
              label = "Object Count"
            }
          }
        }
      },
      # Application Error Rate
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6
        properties = {
          metrics = [
            [
              "${var.project_name}/${var.environment}",
              "ErrorCount",
              {
                stat  = "Sum"
                color = "#FF0000"
              }
            ]
          ]
          period = 60
          stat   = "Sum"
          region = data.aws_region.current.name
          title  = "Application Errors"
          yAxis = {
            left = {
              label = "Error Count"
              min   = 0
            }
          }
        }
      },
      # Response Time Distribution
      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6
        properties = {
          metrics = [
            [
              "${var.project_name}/${var.environment}",
              "ResponseTime",
              {
                stat = "Average"
              }
            ],
            [
              "...",
              {
                stat  = "p50"
                label = "p50"
              }
            ],
            [
              "...",
              {
                stat  = "p90"
                label = "p90"
              }
            ],
            [
              "...",
              {
                stat  = "p99"
                label = "p99"
              }
            ]
          ]
          period = 60
          region = data.aws_region.current.name
          title  = "Response Time Distribution"
          yAxis = {
            left = {
              label = "Milliseconds"
            }
          }
        }
      }
    ]
  })
}