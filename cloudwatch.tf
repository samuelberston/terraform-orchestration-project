# Create a CloudWatch log group
resource "aws_cloudwatch_log_group" "app_log_group" {
  name              = "/aws/ec2/app-logs"
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
