# Fetch the public IP of the C9 instance
data "http" "c9_public_ip" {
  url = "https://api.ipify.org"
}

# Bastion Security Group
resource "aws_security_group" "bastion-sg" {
  description = "Nextcloud Security Group"
  vpc_id = aws_vpc.vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_bastion_ssh_ipv4_in" {
  security_group_id = aws_security_group.bastion-sg.id
  cidr_ipv4         = "${data.http.c9_public_ip.response_body}/32"
#  cidr_ipv4   = "195.7.117.146/32"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

#Commented out for internet access
#resource "aws_vpc_security_group_egress_rule" "allow_bastion_ssh_ipv4_out" {
#  security_group_id = aws_security_group.bastion-sg.id
#  cidr_ipv4         = "${aws_instance.nextcloud.private_ip}/32"
#  from_port         = 22
#  ip_protocol       = "tcp"
#  to_port           = 22
#}

#Internet access to bastion VM
resource "aws_vpc_security_group_egress_rule" "allow_bastion_ssh_ipv4_out" {
  security_group_id = aws_security_group.bastion-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Nextcloud Security Group
resource "aws_security_group" "nextcloud-sg" {
  description = "Nextcloud Security Group"
  vpc_id = aws_vpc.vpc.id
}

#Removing ingress restriction on Nextcloud instance
#resource "aws_vpc_security_group_ingress_rule" "allow_nextcloud_ssh_ipv4_in" {
#  security_group_id = aws_security_group.nextcloud-sg.id
#  cidr_ipv4         = "${aws_instance.bastion.private_ip}/32"
#  from_port         = 22
#  ip_protocol       = "tcp"
#  to_port           = 22
#}

resource "aws_vpc_security_group_ingress_rule" "allow_nextcloud_ssh_ipv4_in" {
  security_group_id = aws_security_group.nextcloud-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  ip_protocol       = "-1"
  to_port           = 0
}

resource "aws_vpc_security_group_egress_rule" "allow_nextcloud_all_ipv4_out" {
  security_group_id = aws_security_group.nextcloud-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# EFS Security Group
resource "aws_security_group" "efs-sg" {
  description = "EFS Security Group"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_efs_nfs_ipv4_in" {
  security_group_id = aws_security_group.efs-sg.id
  cidr_ipv4         = "${aws_instance.nextcloud.private_ip}/32"
  from_port         = 2049
  ip_protocol       = "tcp"
  to_port           = 2049
}

resource "aws_vpc_security_group_egress_rule" "allow_efs_all_ipv4_out" {
  security_group_id = aws_security_group.efs-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#ACL restraining access to ressources from C9 instances
resource "aws_network_acl" "acl" {
  vpc_id = aws_vpc.vpc.id
  
  ingress {
    protocol   = "tcp"
    rule_no    = 50
    action     = "deny"
    cidr_block = "13.38.91.0/24"
    from_port  = 22
    to_port    = 22
  }
}

#Applying ACL to all VPC subnets
resource "aws_network_acl_association" "acl_association_private_subnets" {
  network_acl_id = aws_network_acl.acl.id
  for_each       = aws_subnet.private_subnets
  subnet_id      = each.value.id
}

##Applying ACL to all VPC subnets
#resource "aws_network_acl_association" "acl_association_public_subnets" {
#  network_acl_id = aws_network_acl.acl.id
#  for_each       = aws_subnet.public_subnets
#  subnet_id      = each.value.id
#}



