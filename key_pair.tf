resource "tls_private_key" "terraform_orchestration_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "terraform_ssh_key" {
  key_name   = "terraform_key"
  public_key = tls_private_key.terraform_orchestration_ssh_key.public_key_openssh
}

# Output the private key to a file for local use
output "private_key_pem" {
  value     = tls_private_key.terraform_orchestration_ssh_key.private_key_pem
  sensitive = true
}
