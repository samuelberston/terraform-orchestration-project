# Create a CloudWatch log group
resource "aws_cloudwatch_log_group" "app_log_group" {
  name              = "/aws/cloudtrail/logs"
  retention_in_days = 7

  tags = {
    Name = "EC2 App Log Group"
  }
}

# CloudWatch log stream for the EC2 instance
resource "aws_cloudwatch_log_stream" "app_log_stream" {
  name           = "app-log-stream"
  log_group_name = aws_cloudwatch_log_group.app_log_group.name
}

# IAM role for CloudTrail to send logs to CloudWatch
resource "aws_iam_role" "cloudwatch_role" {
  name = "cloudwatch-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM policy for CloudWatch to access CloudTrail logs
resource "aws_iam_policy" "cloudwatch_policy" {
  name = "cloudwatch-logs-access-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:PutLogEvents",
          "logs:CreateLogStream",
        ],
        Resource : [
          "arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:log-group:/aws/cloudtrail/logs:*",
        ]
      }
    ]
  })
}

# Attach CloudWatch policy to role 
resource "aws_iam_role_policy_attachment" "attach_cloudwatch_policy" {
  role       = aws_iam_role.cloudwatch_role.name
  policy_arn = aws_iam_policy.cloudwatch_policy.arn
}
