resource "aws_instance" "nextcloud_instance" {
  count = 3 # Adjust based on the number of instances needed
  ami           = "ami-xxxxxx" # Replace with your Ubuntu AMI ID
  instance_type = "t3.micro" # Adjust based on your requirements
  subnet_id     = aws_subnet.public.id # Place the instance in the appropriate subnet
  security_groups = [aws_security_group.nextcloud-sg.id]

  # User data script to install NFS and mount EFS
  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install -y nfs-common  # Install the necessary NFS package for Ubuntu
    mkdir -p /mnt/efs
    echo "${aws_efs_file_system.nextcloud_efs.id}.efs.${var.region}.amazonaws.com:/ /mnt/efs nfs4 defaults,_netdev 0 0" >> /etc/fstab
    mount -a
  EOF

  tags = {
    Name = "Nextcloud Instance"
  }
}


NAT gateway semble ne pas fonctionner pour instance nextcloud