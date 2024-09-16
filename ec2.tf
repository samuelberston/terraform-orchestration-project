# Create an EC2 Instance in the Public Subnet 1
resource "aws_instance" "terraform_orchestration_react_client_instance" {
  ami                         = "ami-0182f373e66f89c85" # Amazon Linux
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.terraform_orchestration_public_subnet_1.id
  key_name                    = aws_key_pair.terraform_ssh_key.key_name
  associate_public_ip_address = true # Assigns a public IP for SSH and HTTP/HTTPS access

  # Use the Security Group
  vpc_security_group_ids = [aws_security_group.terraform_orchestration_ec2_public_sg.id]

  tags = {
    Name = "terraform-orchestration-react-client-ec2-1"
  }

  # User data to initialize the React app on instance launch
  user_data = <<-EOF
              #!/bin/bash
              # Install Node.js and serve React app
              sudo apt update -y
              sudo apt install -y nodejs npm
              # Example: Clone and run your React app
              # git clone https://github.com/samuelberston/todo-app.git
              # cd todo-app
              # npm install
              # npm start
              EOF
}

# Create an EC2 Instance in the Public Subnet 2
resource "aws_instance" "terraform_orchestration_react_client_instance_2" {
  ami                         = "ami-0182f373e66f89c85" # Amazon Linux
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.terraform_orchestration_public_subnet_2.id
  key_name                    = aws_key_pair.terraform_ssh_key.key_name
  associate_public_ip_address = true # Assigns a public IP for SSH and HTTP/HTTPS access

  # Use the Security Group
  vpc_security_group_ids = [aws_security_group.terraform_orchestration_ec2_public_sg.id]

  tags = {
    Name = "terraform-orchestration-react-client-ec2-2"
  }

  # User data to initialize the React app on instance launch
  user_data = <<-EOF
              #!/bin/bash
              # Install Node.js and serve React app
              sudo apt update -y
              sudo apt install -y nodejs npm
              # Example: Clone and run your React app
              # git clone https://github.com/samuelberston/todo-app.git
              # cd todo-app
              # npm install
              # npm start
              EOF
}

# EC2 instance in Private Subnet 1 (for backend)
resource "aws_instance" "private_ec2_instance_1" {
  ami                    = "ami-0182f373e66f89c85" # Amazon Linux
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.ec2_secretsmanager_instance_profile.name
  subnet_id              = aws_subnet.terraform_orchestration_private_subnet_1.id
  key_name               = aws_key_pair.terraform_ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.backend_ec2_sg.id] # Backend EC2 security group

  tags = {
    Name = "terraform-orchestration-nodejs-server-ec2-1"
  }
}

# EC2 instance in Private Subnet 2 (for backend)
resource "aws_instance" "private_ec2_instance_2" {
  ami                    = "ami-0182f373e66f89c85" # Amazon Linux
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.ec2_secretsmanager_instance_profile.name
  subnet_id              = aws_subnet.terraform_orchestration_private_subnet_2.id
  key_name               = aws_key_pair.terraform_ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.backend_ec2_sg.id] # Backend EC2 security group

  tags = {
    Name = "terraform-orchestration-nodejs-server-ec2-2"
  }
}
