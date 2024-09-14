# Security group for the RDS instance
resource "aws_security_group" "rds_postgres_sg" {
  name        = "rds-postgres-sg"
  description = "Allow PostgreSQL traffic from Node.js EC2 instances"
  vpc_id      = aws_vpc.terraform_orchestration_vpc.id

  # Allow incoming traffic on PostgreSQL port from the Node.js EC2 security group
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_ec2_sg.id]  # Allow from Node.js EC2 security group
  }

  # Allow all outbound traffic from the RDS instance
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-postgres-sg"
  }
}

# Subnet group for the RDS instance
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [
    aws_subnet.terraform_orchestration_private_subnet_1.id,
    aws_subnet.terraform_orchestration_private_subnet_2.id
  ]

  tags = {
    Name = "rds-subnet-group"
  }
}
