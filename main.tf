# Define AWS provider
provider "aws" {
  region = "us-east-1"  # Specify your desired AWS region
}
# Define Provider version
terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.44.0"
    }
  }
}

# Create EC2 instance
resource "aws_instance" "web2" {
  ami           = data.aws_ami.amazon_linux_2.id  # Specify your desired AMI ID
  instance_type = "t2.micro"      # Specify your desired instance type
  /*key_name      = "db-connect-key.pem"  # Specify the name of the existing key pair  - did not work; 
  error key pair not found ??*/

}

resource "tls_private_key" "my_key" {
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


resource "aws_key_pair" "my_key24" {
  key_name   = "my-key24"
  public_key = "${file("~/Downloads/UtrainDownloads/my_key24.pem")}"
  depends_on = [ aws_instance.web2 ]
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true

}

# Output the private IP address of the EC2 instance
output "private_ip" {
  value = aws_instance.web2.private_ip
}

# Provisioner to write private IP address to file
resource "null_resource" "write_ip_to_file" {
  provisioner "local-exec" {
    command = "echo ${aws_instance.web2.private_ip} > serverIp.log"
  }
  depends_on = [aws_instance.web2]
}

# Provisioner to copy file to EC2 instance
resource "null_resource" "copy_file_to_instance" {
  provisioner "file" {
    source      = "serverIp.log"
    destination = "/opt/serverIp.log"
    # Connection details to connect to the EC2 instance
    connection {
      type     = "ssh"
      user     = "ec2-user"  # Specify the appropriate user for your AMI
      private_key = file("~/Downloads/UtrainsDownloads/my_key24.pem")  # Specify the path to your SSH private key
      host     = aws_instance.web2.private_ip
    }
  }
  depends_on = [null_resource.write_ip_to_file]
}

/* Cannot create an instance with a key pair in order to copy the file; 
however, the instance can be created and the severlp.log file can be created 
w/o identifying or creating a key pair, so it's half successful :( */