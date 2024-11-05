# Bastion SSH key
resource "tls_private_key" "bastion" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Nextcloud SSH key
resource "tls_private_key" "nextcloud" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Export Bastion SSH key to C9 instance
resource "local_file" "bastion-ssh" {
  content = tls_private_key.bastion.private_key_openssh
  filename = "./ssl/bastion-ssh"
}

# Export Nextcloud SSH key to C9 instance
resource "local_file" "nextcloud-ssh" {
  content = tls_private_key.nextcloud.private_key_openssh
  filename = "./ssl/nextcloud-ssh"
}

# Import Bastion SSH key in AWS
resource "aws_key_pair" "bastion" {
  key_name   = "${local.name}-bastion"
  public_key = tls_private_key.bastion.public_key_openssh
}

# Import Nextcloud SSH key in AWS
resource "aws_key_pair" "nextcloud" {
  key_name   = "${local.name}-nextcloud"
  public_key = tls_private_key.nextcloud.public_key_openssh
}
