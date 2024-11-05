# Bastion Security Group
resource "aws_security_group" "bastion-sg" {
  vpc_id = aws_vpc.vpc.id

#  ingress {
#    from_port   = 22
#    to_port     = 22
#    protocol    = "tcp"
#    cidr_blocks = ["13.38.45.246/32"]  # Restrict SSH access to C9 instance
#  }
#
#  egress { #Should be restricted to ssh to nextcloud instance
#    from_port   = 22
#    to_port     = 22
#    protocol    = "tcp"
#    cidr_blocks = ["${aws_instance.nextcloud.private_ip}"/32]
#  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_bastion_ssh_ipv4_in" {
  security_group_id = aws_security_group.bastion-sg.id
  cidr_ipv4         = ["13.38.45.246/32/32"] # Make dynamic
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_bastion_ssh_ipv4_out" {
  security_group_id = aws_security_group.bastion-sg.id
  cidr_ipv4         = "${aws_instance.nextcloud.public_ip}"/32
  ip_protocol       = "tcp"
}

# Nextcloud Security Group
resource "aws_security_group" "nextcloud-sg" {
  vpc_id = aws_vpc.vpc.id

# ingress { #Should be restricted to ssh of bastion instance
#   from_port   = 22
#   to_port     = 22
#   protocol    = "tcp"
#   cidr_blocks = ["${aws_instance.bastion.public_ip}"/32]
# }
#
# egress { #Should be restricted?
#   from_port   = 0
#   to_port     = 0
#   protocol    = "-1"
#   cidr_blocks = ["0.0.0.0/0"]
# }
}

resource "aws_vpc_security_group_ingress_rule" "allow_nextcloud_ssh_ipv4_in" {
  security_group_id = aws_security_group.nextcloud-sg.id
  cidr_ipv4         = "${aws_instance.bastion.public_ip}"/32
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_nextcloud_all_ipv4_out" {
  security_group_id = aws_security_group.nextcloud-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
