# Security Group for Reactjs EC2 Instances (React Client)
resource "aws_security_group" "terraform_orchestration_ec2_public_sg" {
  vpc_id = aws_vpc.terraform_orchestration_vpc.id

  # Allow HTTP traffic on port 80 from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH access from your IP only
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["98.33.58.29/32"] # Replace with your public IP
  }

  # Allow all outbound traffic from the instance
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-public-sg"
  }
}

# Security group for Nodejs Backend EC2 instances (private subnets)
resource "aws_security_group" "backend_ec2_sg" {
  vpc_id = aws_vpc.terraform_orchestration_vpc.id

  # Allow inbound HTTP traffic from the Internal ALB
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.private_alb_sg.id]  # Internal ALB security group
  }

  # Allow all outbound traffic (for internet access via NAT Gateway)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "backend-ec2-sg"
  }
}


# Security group for the public ALB
resource "aws_security_group" "tf_alb_sg" {
  vpc_id = aws_vpc.terraform_orchestration_vpc.id

  # Allow inbound HTTPS traffic on port 443 from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound HTTP traffic to EC2 instances on port 80
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tf-alb-sg"
  }
}

# Security group for the Internal ALB
resource "aws_security_group" "private_alb_sg" {
  vpc_id = aws_vpc.terraform_orchestration_vpc.id

  # Allow HTTP traffic from ReactJS EC2 instances in the public subnet
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24"]  # CIDR block of the public subnets
  }

  # Allow outbound traffic to the backend EC2 instances in the private subnet
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.3.0/24", "10.0.4.0/24"]  # CIDR blocks of private subnets
  }

  tags = {
    Name = "private-alb-sg"
  }
}
