# Retrieve the latest Ubuntu AMD64 AMI
data "aws_ami" "ubuntu_latest" {
  most_recent = true

  owners = ["099720109477"] # Canonical's AWS Account ID

  filter {
    name   = "name"
    values = ["ubuntu*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


#Create Nextcloud VM
resource "aws_instance" "nextcloud" {
  ami = data.aws_ami.ubuntu_latest.id
  instance_type = "t3.micro"
  subnet_id = aws_subnet.private_subnets[keys(aws_subnet.private_subnets)[0]].id
  vpc_security_group_ids = [aws_security_group.nextcloud-sg.id]
  key_name = aws_key_pair.nextcloud.key_name

  tags = {
    Name = "${local.name}-nextcloud"
  }
}

#Create Bastion VM
resource "aws_instance" "bastion" {
  ami = data.aws_ami.ubuntu_latest.id
  instance_type = "t3.micro"
  subnet_id = aws_subnet.public_subnets[keys(aws_subnet.public_subnets)[0]].id
  vpc_security_group_ids = [aws_security_group.bastion-sg.id]
  key_name = aws_key_pair.bastion.key_name
  tags = {
    Name = "${local.name}-bastion"
  }
}