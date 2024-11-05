# Bastion Security Group
resource "aws_security_group" "bastion-sg" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["13.38.45.246/32"]  # Restrict SSH access to C9 instance
  }

  egress { #Should be restricted to ssh to nextcloud instance
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_instance.nextcloud.private_ip]
  }
}

# Nextcloud Security Group
resource "aws_security_group" "nextcloud-sg" {
  vpc_id = aws_vpc.vpc.id

  ingress { #Should be restricted to ssh of bastion instance
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_instance.bastion.public_ip]  
  }

  egress { #Should be restricted?
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}