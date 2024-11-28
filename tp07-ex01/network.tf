#Retrieve 3 available AZs
data "aws_availability_zones" "available" {}
data "aws_region" "current" {}
locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
  #subnet = {for idx, az in local.azs : idx => az} # Legacy stuff :p
  private_subnet = {for idx, az in local.azs : az => cidrsubnet(aws_vpc.vpc.cidr_block, 8, idx)}
  public_subnet = {for idx, az in local.azs : az => cidrsubnet(aws_vpc.vpc.cidr_block, 8, idx + 100)}
}

#Deploy VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
}

#Deploy the private subnets
resource "aws_subnet" "private_subnets" {
  for_each = local.private_subnet
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value
  availability_zone = each.key
}

#Deploy the public subnets
resource "aws_subnet" "public_subnets" {
  for_each = local.public_subnet
  vpc_id                  = aws_vpc.vpc.id
  cidr_block        = each.value
  availability_zone = each.key
  map_public_ip_on_launch = true
}

#Deploy DB subnet group
resource "aws_db_subnet_group" "rds_subnet" {
  subnet_ids = values(aws_subnet.private_subnets)[*].id
}

#Create route tables for public and private subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
}

#Create route table associations
resource "aws_route_table_association" "public" {
  depends_on     = [aws_subnet.public_subnets]
  route_table_id = aws_route_table.public_route_table.id
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
}

resource "aws_route_table_association" "private" {
  depends_on     = [aws_subnet.private_subnets]
  route_table_id = aws_route_table.private_route_table.id
  for_each       = aws_subnet.private_subnets
  subnet_id      = each.value.id
}

#Create Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
}

#Create EIP
resource "aws_eip" "eip" {
  domain   = "vpc"
}

#Create NAT gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip.allocation_id
  subnet_id     = values(aws_subnet.public_subnets)[0].id
  depends_on = [aws_internet_gateway.internet_gateway]
}

#Creating Application Load Balancer
resource "aws_lb" "nextcloud" {
  name = "${local.name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb-sg.id]
  subnets            = [for subnet in aws_subnet.public_subnets : subnet.id]
  enable_deletion_protection = false
}

#Setting ALB target group
resource "aws_lb_target_group" "nextcloud" {
  name = "${local.name}-alb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id

  target_group_health {
   dns_failover {
     minimum_healthy_targets_count      = "1"
     minimum_healthy_targets_percentage = "off"
   }
   unhealthy_state_routing {
     minimum_healthy_targets_count      = "1"
     minimum_healthy_targets_percentage = "off"
   }
  }
}

#Attach Nextcloud instance to nextcloud ALB target group
resource "aws_lb_target_group_attachment" "nextcloud" {
  target_group_arn = aws_lb_target_group.nextcloud.arn
  target_id        = aws_instance.nextcloud.id
  port             = 80
}

#Config ALB listener
resource "aws_lb_listener" "nextcloud" {
  load_balancer_arn = aws_lb.nextcloud.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.nextcloud.arn
  }
}

