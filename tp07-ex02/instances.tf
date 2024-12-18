## Retrieve the latest Ubuntu AMD64 AMI
## Retrieve the latest Ubuntu 22.04 LTS AMD64 AMI
#data "aws_ami" "ubuntu_latest" {
#  most_recent = true
#
#  owners = ["099720109477"] # Canonical's AWS Account ID
#
#  filter {
#    name   = "name"
#    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
#  }
#
#  filter {
#    name   = "virtualization-type"
#    values = ["hvm"]
#  }
#}

# Recover custom made AMI
data "aws_ami" "nextcloud_custom" {
  most_recent = true

  owners = ["self"]

  filter {
    name   = "name"
    values = ["${local.user}-${local.tp}-nextcloud*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}


##Create Nextcloud Instance
#resource "aws_instance" "nextcloud" {
#  ami                    = data.aws_ami.ubuntu_latest.id
#  instance_type          = "t3.micro"
#  subnet_id              = values(aws_subnet.private_subnets)[0].id
#  vpc_security_group_ids = [aws_security_group.nextcloud-sg.id]
#  key_name               = aws_key_pair.nextcloud.key_name
#  user_data              = local.nextcloud_userdata
#
#  tags = {
#    Name = "${local.name}-nextcloud"
#  }
#}

resource "aws_launch_template" "nextcloud" {
  name_prefix   = "${local.name}-nextcloud-lt"
  image_id      = data.aws_ami.nextcloud_custom.id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.nextcloud.key_name
  vpc_security_group_ids = [aws_security_group.nextcloud-sg.id]
  
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name  = "${local.name}-nextcloud-instance"
      Owner = local.user
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name  = "${local.name}-nextcloud-volume"
      Owner = local.user
    }
  }

  tag_specifications {
    resource_type = "network-interface"
    tags = {
      Name  = "${local.name}-nextcloud-nic"
      Owner = local.user
    }
  }

  tags = {
    Name  = "${local.name}-nextcloud-lt"
    Owner = local.user
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
  db_name                = "nextcloudDB"
  allocated_storage      = 20
  instance_class         = "db.t4g.micro"
  engine                 = "mysql"
  engine_version         = "8.0"
  username               = "admin"
  password               = "securepassword"
  multi_az               = true
  identifier             = "${local.name}-nextcloud-db"
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet.name
  vpc_security_group_ids = [aws_security_group.rds-sg.id]
  skip_final_snapshot    = true
}
