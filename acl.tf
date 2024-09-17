# Network ACLs for the private subnet
# Enable ingress from the public subnets on HTTP/S and SSH ports 
# Enable egress to the PostgreSQL RDS and the NAT Gateway

# Create the Network ACL for private subnets
resource "aws_network_acl" "private_subnet_nacl" {
  vpc_id = aws_vpc.terraform_orchestration_vpc.id

  tags = {
    Name = "Private Subnet NACL"
  }
}

# Allow inbound HTTP traffic (port 80) from public subnet 1 
resource "aws_network_acl_rule" "allow_http_inbound_from_public_1" {
  network_acl_id = aws_network_acl.private_subnet_nacl.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = aws_subnet.terraform_orchestration_public_subnet_1.cidr_block # Public subnet 1 CIDR
  from_port      = 80
  to_port        = 80

  # adding this due to issues with the state thinking the cidr_block is updated 
  lifecycle {
    ignore_changes = [cidr_block]
  }
}

# Allow inbound HTTPS traffic (port 443) from public subnet 1
resource "aws_network_acl_rule" "allow_https_inbound_from_public_1" {
  network_acl_id = aws_network_acl.private_subnet_nacl.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = aws_subnet.terraform_orchestration_public_subnet_1.cidr_block # Public subnet 1 CIDR
  from_port      = 443
  to_port        = 443
}

# Allow inbound SSH traffic (port 22) from public subnet 1
resource "aws_network_acl_rule" "allow_ssh_inbound_from_public_1" {
  network_acl_id = aws_network_acl.private_subnet_nacl.id
  rule_number    = 120
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = aws_subnet.terraform_orchestration_public_subnet_1.cidr_block # Public subnet 1 CIDR
  from_port      = 22
  to_port        = 22

  # adding this due to issues with the state thinking the cidr_block is updated 
  lifecycle {
    ignore_changes = [cidr_block]
  }
}

# Allow inbound HTTP traffic (port 80) from public subnet 2 
resource "aws_network_acl_rule" "allow_http_inbound_from_public_2" {
  network_acl_id = aws_network_acl.private_subnet_nacl.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = aws_subnet.terraform_orchestration_public_subnet_2.cidr_block # Public subnet 1 CIDR
  from_port      = 80
  to_port        = 80

  # adding this due to issues with the state thinking the cidr_block is updated 
  lifecycle {
    ignore_changes = [cidr_block, protocl]
  }
}

# Allow inbound HTTPS traffic (port 443) from public subnet 2
resource "aws_network_acl_rule" "allow_https_inbound_from_public_2" {
  network_acl_id = aws_network_acl.private_subnet_nacl.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = aws_subnet.terraform_orchestration_public_subnet_1.cidr_block # Public subnet 1 CIDR
  from_port      = 443
  to_port        = 443
}

# Allow inbound SSH traffic (port 22) from public subnet 2
resource "aws_network_acl_rule" "allow_ssh_inbound_from_public_2" {
  network_acl_id = aws_network_acl.private_subnet_nacl.id
  rule_number    = 120
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = aws_subnet.terraform_orchestration_public_subnet_2.cidr_block # Public subnet 2 CIDR
  from_port      = 22
  to_port        = 22

  # adding this due to issues with the state thinking the cidr_block is updated 
  lifecycle {
    ignore_changes = [cidr_block, protocl]
  }
}

# Allow outbound PostgreSQL traffic (port 5432) to the RDS subnets
resource "aws_network_acl_rule" "allow_postgres_outbound_to_rds" {
  network_acl_id = aws_network_acl.private_subnet_nacl.id
  rule_number    = 200
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"

  # CIDR blocks for the private subnets where the RDS instance is running
  cidr_block = aws_subnet.terraform_orchestration_private_subnet_1.cidr_block # Private subnet 1 CIDR
  from_port  = 5432
  to_port    = 5432
}

# Add another rule for the second private subnet CIDR
resource "aws_network_acl_rule" "allow_postgres_outbound_to_rds_2" {
  network_acl_id = aws_network_acl.private_subnet_nacl.id
  rule_number    = 210
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"

  # CIDR block for the second private subnet
  cidr_block = aws_subnet.terraform_orchestration_private_subnet_2.cidr_block # Private subnet 2 CIDR
  from_port  = 5432
  to_port    = 5432
}

# Allow outbound traffic to the internet via NAT gateway
resource "aws_network_acl_rule" "allow_outbound_nat" {
  network_acl_id = aws_network_acl.private_subnet_nacl.id
  rule_number    = 110
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0" # Outbound to the internet via NAT
  from_port      = 0
  to_port        = 0
}
