# Create an IAM role for the EC2 instance to access Secrets Manager
resource "aws_iam_role" "ec2_secretsmanager_role" {
  name = "ec2-secretsmanager-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Create a policy that allows the EC2 instance to read the secret
resource "aws_iam_policy" "ec2_secretsmanager_policy" {
  name = "ec2-secretsmanager-access-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = aws_secretsmanager_secret.rds_password.arn
      }
    ]
  })
}

# Attach the policy to the EC2 IAM role
resource "aws_iam_role_policy_attachment" "attach_secretsmanager_policy" {
  role       = aws_iam_role.ec2_secretsmanager_role.name
  policy_arn = aws_iam_policy.ec2_secretsmanager_policy.arn
}
