resource "aws_vpc" "terraform_orchestration_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "terraform-orchestration-vpc"
  }
}

# Create Internet Gateway for Public Subnet
resource "aws_internet_gateway" "terraform_orchestration_igw" {
  vpc_id = aws_vpc.terraform_orchestration_vpc.id
  tags = {
    Name = "terraform-orchestration-igw"
  }
}

# Create Public Subnet
resource "aws_subnet" "terraform_orchestration_public_subnet" {
  vpc_id            = aws_vpc.terraform_orchestration_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true  # This allows public IP addresses for instances in this subnet
  tags = {
    Name = "terraform-orchestration-public-subnet"
  }
}

# Create Route Table for Public Subnet
resource "aws_route_table" "terraform_orchestration_public_route_table" {
  vpc_id = aws_vpc.terraform_orchestration_vpc.id
  route {
    cidr_block = "0.0.0.0/0"  # Route all outbound traffic to the internet
    gateway_id = aws_internet_gateway.terraform_orchestration_igw.id
  }
  tags = {
    Name = "terraform-orchestration-public-route-table"
  }
}

# Associate Public Subnet with Public Route Table
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.terraform_orchestration_public_subnet.id
  route_table_id = aws_route_table.terraform_orchestration_public_route_table.id
}

# Create Elastic IP for NAT Gateway (Public Subnet)
resource "aws_eip" "terraform_orchestration_nat_eip" {
  domain = "vpc"
}

# Create NAT Gateway in the Public Subnet
resource "aws_nat_gateway" "terraform_orchestration_nat_gateway" {
  allocation_id = aws_eip.terraform_orchestration_nat_eip.id
  subnet_id     = aws_subnet.terraform_orchestration_public_subnet.id  # NAT in Public Subnet
  tags = {
    Name = "terraform-orchestration-nat-gateway"
  }
}

# Create Private Subnet
resource "aws_subnet" "terraform_orchestration_private_subnet" {
  vpc_id            = aws_vpc.terraform_orchestration_vpc.id
  cidr_block        = "10.0.2.0/24"  # Private subnet range
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = false  # No public IPs for instances in this subnet
  tags = {
    Name = "terraform-orchestration-private-subnet"
  }
}

# Create Private Route Table for Private Subnet
resource "aws_route_table" "terraform_orchestration_private_route_table" {
  vpc_id = aws_vpc.terraform_orchestration_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"  # Route all outbound traffic to the NAT Gateway
    nat_gateway_id = aws_nat_gateway.terraform_orchestration_nat_gateway.id
  }

  tags = {
    Name = "terraform-orchestration-private-route-table"
  }
}

# Associate Private Subnet with Private Route Table
resource "aws_route_table_association" "private_association" {
  subnet_id      = aws_subnet.terraform_orchestration_private_subnet.id
  route_table_id = aws_route_table.terraform_orchestration_private_route_table.id
}
