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
    security_groups = [aws_security_group.backend_ec2_sg.id] # Allow from Node.js EC2 security group
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
  name = "rds-subnet-group"
  subnet_ids = [
    aws_subnet.terraform_orchestration_private_subnet_1.id,
    aws_subnet.terraform_orchestration_private_subnet_2.id
  ]

  tags = {
    Name = "rds-subnet-group"
  }
}

variable "RDS_PASSWORD" {
  description = "The password for the RDS instance"
  type        = string
  sensitive   = true
}

resource "aws_secretsmanager_secret" "rds_password" {
  name        = "rds-database-password"
  description = "Password for the RDS database"
}

resource "aws_secretsmanager_secret_version" "rds_password_version" {
  secret_id = aws_secretsmanager_secret.rds_password.id
  secret_string = jsonencode({
    username = "postgres",
    password = var.RDS_PASSWORD # Reference the password from the variable
  })
}

# PostgreSQL RDS instance
resource "aws_db_instance" "postgres_rds" {
  identifier             = "terraform-postgres-rds"
  allocated_storage      = 20
  engine                 = "postgres"
  instance_class         = "db.t3.micro"
  db_name                = "tfPostgresDB"
  username               = jsondecode(aws_secretsmanager_secret_version.rds_password_version.secret_string).username
  password               = jsondecode(aws_secretsmanager_secret_version.rds_password_version.secret_string).password
  parameter_group_name   = "default.postgres16"
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_postgres_sg.id]
  skip_final_snapshot    = true # FOR TESTING - Skip final snapshot on delete (use with caution)

  # Disable public access
  publicly_accessible = false

  tags = {
    Name = "terraform-postgres-rds"
  }
}
