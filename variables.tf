# Declare the variable for the self-signed certificate
variable "SELFSIGNED_CERT" {
  type = string
  description = "The self-signed certificate body"
}

# Declare the variable for the private key
variable "SELFSIGNED_KEY" {
  type = string
  description = "The private key for the self-signed certificate"
}
