provider "aws" {
  region     = "us-east-1"
  access_key = ""
  secret_key = ""
}

# Generate a private key
resource "tls_private_key" "terratass_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS key pair from public key
resource "aws_key_pair" "terratass_keypair" {
  key_name   = "terratass"
  public_key = tls_private_key.terratass_key.public_key_openssh
}

# Save the private key locally
resource "local_file" "private_key" {
  content         = tls_private_key.terratass_key.private_key_pem
  filename        = "${path.module}/terratass.pem"
  file_permission = "0400"
}
resource "aws_security_group" "ssh_access" {
  name        = "ssh_access"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


}
resource "aws_instance" "ubuntu_ec2" {
  ami           = "ami-084568db4383264d4"
  instance_type = "t2.micro"
  key_name      = "terratass"
  security_groups = [aws_security_group.ssh_access.name]
  tags = {
    Name = "Ubuntu-EC2-Terratass"
  }
}
