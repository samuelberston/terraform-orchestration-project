# Create Security Group for Public Subnet
resource "aws_security_group" "terraform_orchestration_public_sg" {
  vpc_id = aws_vpc.terraform_orchestration_vpc.id

  # Allow inbound HTTP traffic from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound HTTPS traffic from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound SSH traffic from my IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["98.33.58.29/32"]  # my IP
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-orchestration-public-sg"
  }
}


# Security Group for Private Subnet
resource "aws_security_group" "terraform_orchestration_private_sg" {
  vpc_id = aws_vpc.terraform_orchestration_vpc.id

  # Allow inbound HTTP traffic from Public Subnet
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.terraform_orchestration_public_subnet.cidr_block]
  }

  # Allow inbound HTTPS traffic from Public Subnet
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.terraform_orchestration_public_subnet.cidr_block]
  }

  # Allow inbound SSH traffic from Public Subnet
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.terraform_orchestration_public_subnet.cidr_block]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-orchestration-private-sg"
  }
}
