# Fetch the public IP of the C9 instance
data "http" "c9_public_ip" {
  url = "https://api.ipify.org"
}

# Bastion Security Group
resource "aws_security_group" "bastion-sg" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_bastion_ssh_ipv4_in" {
  security_group_id = aws_security_group.bastion-sg.id
  cidr_ipv4         = ["${data.http.c9_public_ip.body}/32"]
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_bastion_ssh_ipv4_out" {
  security_group_id = aws_security_group.bastion-sg.id
  cidr_ipv4         = "${aws_instance.nextcloud.private_ip}/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# Nextcloud Security Group
resource "aws_security_group" "nextcloud-sg" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_nextcloud_ssh_ipv4_in" {
  security_group_id = aws_security_group.nextcloud-sg.id
  cidr_ipv4         = "${aws_instance.bastion.private_ip}/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_nextcloud_all_ipv4_out" {
  security_group_id = aws_security_group.nextcloud-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
