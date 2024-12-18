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
  ami                    = data.aws_ami.ubuntu_latest.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private_subnets[keys(aws_subnet.private_subnets)[0]].id #Ugly
  vpc_security_group_ids = [aws_security_group.nextcloud-sg.id]
  key_name               = aws_key_pair.nextcloud.key_name
  #  user_data = "${file("nextcloud-config.sh")}"
  user_data = <<-EOF
    #!/bin/bash

    # Update system and ensure everything is up to date.
    apt update -y && sudo apt upgrade -y
    
    # Install requirement to mount EFS.
    apt install nfs-common -y
    
    # Create EFS mount directory.
    mkdir /mnt/efs
    
    # Mount EFS using the previously created directory. DNS is required.
    mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 \
    ${aws_efs_file_system.nextcloud-efs.dns_name}:/ /mnt/efs
    
    # Enabling mount point persistence by appending config to /etc/fstab.
    echo "${aws_efs_file_system.nextcloud-efs.dns_name}:/ /mnt/efs nfs4 defaults,_netdev 0 0" | tee -a /etc/fstab

    EOF

  tags = {
    Name = "${local.name}-nextcloud"
  }
}

#Create Bastion VM
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.ubuntu_latest.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_subnets[keys(aws_subnet.public_subnets)[0]].id #Ugly
  vpc_security_group_ids = [aws_security_group.bastion-sg.id]
  key_name               = aws_key_pair.bastion.key_name
  #  user_data = "${file("bastion-config.sh")}"

  tags = {
    Name = "${local.name}-bastion"
  }
}