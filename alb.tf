# Application Load Balancer (ALB)
resource "aws_lb" "tf_alb" {
  name               = "tf-alb"
  internal           = false # Public-facing ALB
  load_balancer_type = "application"
  security_groups    = [aws_security_group.tf_alb_sg.id] # ALB Security Group
  subnets = [
    aws_subnet.terraform_orchestration_public_subnet_1.id, # Public Subnet 1
    aws_subnet.terraform_orchestration_public_subnet_2.id  # Public Subnet 2
  ]

  tags = {
    Name = "tf-alb"
  }
}

# Target Group for EC2 instances (HTTP traffic forwarded from ALB)
resource "aws_lb_target_group" "tf_target_group" {
  name        = "tf-target-group"
  port        = 80 # Forward traffic to EC2 instances on HTTP
  protocol    = "HTTP"
  vpc_id      = aws_vpc.terraform_orchestration_vpc.id
  target_type = "instance"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

# Declare GitHub Actions input variables for self-signed certificate
variable "SELFSIGNED_CERT" {
  type        = string
  description = "The self-signed certificate body"
}

# Declare variable for private key
variable "SELFSIGNED_KEY" {
  type        = string
  description = "The private key for the self-signed certificate"
}

# Use the self-signed certificate
resource "aws_iam_server_certificate" "my_selfsigned_cert" {
  name             = "tf-selfsigned-cert-v1"
  certificate_body = var.SELFSIGNED_CERT # Use a Terraform variable
  private_key      = var.SELFSIGNED_KEY  # Use a Terraform variable
}

# HTTPS Listener for TLS termination on ALB
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.tf_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"                       # SSL policy for TLS
  certificate_arn   = aws_iam_server_certificate.my_selfsigned_cert.arn # Use self-signed certificate

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tf_target_group.arn
  }
}

# Register Public EC2 instance 1 in the target group
resource "aws_lb_target_group_attachment" "tg_attachment_pubic_1" {
  target_group_arn = aws_lb_target_group.backend_target_group.arn
  target_id        = aws_instance.terraform_orchestration_react_client_instance.id
  port             = 80
}

# Register Public EC2 instance 2 in the target group
resource "aws_lb_target_group_attachment" "tg_attachment_public_2" {
  target_group_arn = aws_lb_target_group.backend_target_group.arn
  target_id        = aws_instance.terraform_orchestration_react_client_instance_2.id
  port             = 80
}



# Private ALB (for backend traffic in private subnets)
resource "aws_lb" "private_alb" {
  name               = "private-alb"
  internal           = true # Private ALB
  load_balancer_type = "application"
  security_groups    = [aws_security_group.private_alb_sg.id] # Security group for Private ALB
  subnets = [
    aws_subnet.terraform_orchestration_private_subnet_1.id,
    aws_subnet.terraform_orchestration_private_subnet_2.id
  ]

  tags = {
    Name = "private-alb"
  }
}

# HTTP listener for Private ALB
resource "aws_lb_listener" "private_http_listener" {
  load_balancer_arn = aws_lb.private_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_target_group.arn
  }
}

# Target group for backend EC2 instances in private subnets
resource "aws_lb_target_group" "backend_target_group" {
  name        = "backend-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.terraform_orchestration_vpc.id
  target_type = "instance"

  health_check {
    path                = "/health" # Replace with your health check path
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

# Register Private EC2 instance 1 in the target group
resource "aws_lb_target_group_attachment" "tg_attachment_private_1" {
  target_group_arn = aws_lb_target_group.backend_target_group.arn
  target_id        = aws_instance.private_ec2_instance_1.id
  port             = 80
}

# Register Private EC2 instance 2 in the target group
resource "aws_lb_target_group_attachment" "tg_attachment_private_2" {
  target_group_arn = aws_lb_target_group.backend_target_group.arn
  target_id        = aws_instance.private_ec2_instance_2.id
  port             = 80
}

