# Bastion Security Group
resource "aws_security_group" "bastion-sg" {
  vpc_id = aws_vpc.vpc.id

#  ingress {
#    from_port   = 22
#    to_port     = 22
#    protocol    = "tcp"
#    cidr_blocks = ["10.0.0.0/16"]  # Restrict SSH access to within VPC
#  }
#
#  egress {
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["0.0.0.0/0"]
#  }

  tags = {
    Name = local.name
  }
}

resource "aws_vpc_security_group_ingress_rule" "bastion_allow_ssh_ipv4_in" {
  security_group_id = aws_security_group.bastion-sg.id
  cidr_ipv4 = aws_vpc.vpc.cidr_block
  from_port = 22
  ip_protocol = "tcp"
  to_port = 22
}

resource "aws_vpc_security_group_egress_rule" "bastion_allow_all_ipv4_out" { #Corriger le nom si changement
  security_group_id = aws_security_group.bastion-sg.id
  cidr_ipv4         = "0.0.0.0/0" #Mettre IP dynamique instance Nextcloud
  ip_protocol       = "-1" #Mettre SSH 
}

# Nextcloud Security Group
resource "aws_security_group" "nextcloud-sg" {
  vpc_id = aws_vpc.vpc.id

#  ingress {
#    from_port   = 22
#    to_port     = 22
#    protocol    = "tcp"
#    cidr_blocks = ["10.0.0.0/16"]  # Restrict SSH access to within VPC
#  }
#
#  egress {
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["0.0.0.0/0"]
#  }

  tags = {
    Name = local.name
  }
}

resource "aws_vpc_security_group_ingress_rule" "nextcloud_allow_ssh_ipv4_in" {
  security_group_id = aws_security_group.nextcloud-sg.id
  cidr_ipv4 = aws_vpc.vpc.cidr_block
  from_port = 22
  ip_protocol = "tcp"
  to_port = 22
}

resource "aws_vpc_security_group_egress_rule" "nextcloud_allow_all_ipv4_out" { #Corriger le nom si changement
  security_group_id = aws_security_group.nextcloud-sg.id
  cidr_ipv4         = "0.0.0.0/0" #Vérifier
  ip_protocol       = "-1" #Vérifier
}