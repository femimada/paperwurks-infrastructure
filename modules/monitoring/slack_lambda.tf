# -----------------------------------------------------------------------------
# Lambda for Slack Notifications (Optional)
# -----------------------------------------------------------------------------

resource "aws_iam_role" "slack_lambda" {
  count = var.slack_webhook_url != "" ? 1 : 0
  name  = "${var.project_name}-${var.environment}-slack-lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-slack-lambda"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "slack_lambda_basic" {
  count      = var.slack_webhook_url != "" ? 1 : 0
  role       = aws_iam_role.slack_lambda[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "slack_lambda" {
  count       = var.slack_webhook_url != "" ? 1 : 0
  type        = "zip"
  output_path = "${path.module}/slack_notifier.zip"

  source {
    content  = <<-EOF
      import json
      import urllib3

      http = urllib3.PoolManager()

      def lambda_handler(event, context):
          message = json.loads(event['Records'][0]['Sns']['Message'])
          
          alarm_name = message.get('AlarmName', 'Unknown Alarm')
          new_state = message.get('NewStateValue', 'UNKNOWN')
          reason = message.get('NewStateReason', 'No reason provided')
          
          color = '#FF0000' if new_state == 'ALARM' else '#00FF00'
          
          slack_message = {
              'attachments': [{
                  'color': color,
                  'title': f'{alarm_name}',
                  'text': f'State: {new_state}\n{reason}',
                  'footer': '${var.project_name} - ${var.environment}'
              }]
          }
          
          encoded_data = json.dumps(slack_message).encode('utf-8')
          resp = http.request('POST', '${var.slack_webhook_url}', body=encoded_data)
          
          return {
              'statusCode': 200,
              'body': json.dumps('Notification sent')
          }
    EOF
    filename = "lambda_function.py"
  }
}

resource "aws_lambda_function" "slack_notifier" {
  count            = var.slack_webhook_url != "" ? 1 : 0
  filename         = data.archive_file.slack_lambda[0].output_path
  function_name    = "${var.project_name}-${var.environment}-slack-notifier"
  role             = aws_iam_role.slack_lambda[0].arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.slack_lambda[0].output_base64sha256
  runtime          = "python3.11"
  timeout          = 30

  environment {
    variables = {
      ENVIRONMENT = var.environment
    }
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-slack-notifier"
    Environment = var.environment
  }
}

resource "aws_lambda_permission" "slack_sns" {
  count         = var.slack_webhook_url != "" ? 1 : 0
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.slack_notifier[0].function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alerts.arn
}