# Retrieve the latest Ubuntu 20.04 LTS AMI
data "aws_ami" "ubuntu_latest" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}


#Create Nextcloud VM
resource "aws_instance" "nextcloud" {
  ami = data.aws_ami.ubuntu_latest.id
  instance_type = "t3.micro"
  subnet_id = aws_subnet.private_subnets["0"].id
  security_groups = [aws_security_group.nextcloud-sg.name]
#  network_interface {
#    device_index = 0
#    network_interface_id = aws_subnet.private_subnets[0]
#  }

  tags = {
    Name = "local.name"
    Owner = "local.user"
  }
}

#Create Bastion VM
resource "aws_instance" "bastion" {
  ami = "ami-00d81861317c2cc1f"
  instance_type = "t3.micro"
  subnet_id = aws_subnet.public_subnets["0"].id
  security_groups = [aws_security_group.bastion-sg.name]
#  network_interface {
#    device_index = 0
#    network_interface_id = aws_subnet.public_subnets[0]
#  }

  tags = {
    Name = "local.name"
    Owner = "local.user"
  }
}