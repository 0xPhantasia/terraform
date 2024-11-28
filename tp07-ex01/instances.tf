# Retrieve the latest Ubuntu AMD64 AMI
# Retrieve the latest Ubuntu 22.04 LTS AMD64 AMI
data "aws_ami" "ubuntu_latest" {
  most_recent = true

  owners = ["099720109477"] # Canonical's AWS Account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

#Create Nextcloud Instance
resource "aws_instance" "nextcloud" {
  ami                    = data.aws_ami.ubuntu_latest.id
  instance_type          = "t3.micro"
  subnet_id              = values(aws_subnet.private_subnets)[0].id
  vpc_security_group_ids = [aws_security_group.nextcloud-sg.id]
  key_name               = aws_key_pair.nextcloud.key_name
  user_data              = local.nextcloud_userdata

  tags = {
    Name = "${local.name}-nextcloud"
  }
}

#Create Bastion Instance
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.ubuntu_latest.id
  instance_type          = "t3.micro"
  subnet_id              = values(aws_subnet.public_subnets)[0].id
  vpc_security_group_ids = [aws_security_group.bastion-sg.id]
  key_name               = aws_key_pair.bastion.key_name
#  user_data = "${file("bastion-config.sh")}"

  tags = {
    Name = "${local.name}-bastion"
  }
}

#Create DB Instance
resource "aws_db_instance" "nextcloud" {
  allocated_storage    = 20
  instance_class       = "db.t4g.micro"
  engine               = "mysql"
  engine_version       = "8.0"
  username             = "admin"
  password             = "securepassword"
  multi_az             = true
  identifier = "${local.name}-nextcloud-db"
  db_subnet_group_name = aws_db_subnet_group.rds_subnet.name
  vpc_security_group_ids = [aws_security_group.rds-sg.id]
  skip_final_snapshot = true
}
