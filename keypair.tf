/*resource "tls_private_key" "my_key" {
  algorithm = "RSA"
  rsa_bits = 2048
}

resource "aws_key_pair" "my_key" {
  public_key = tls_private_key.my_key.public_key_openssh
  key_name = "my_key24"
}

resource "local_file" "keypair" {
  filename = "my_key24.pem"
  content = tls_private_key.my_key.private_key_pem
}   
*/