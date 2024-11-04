#Retrieve 3 available AZs
data "aws_availability_zones" "available" {}
data "aws_region" "current" {}
locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

#Deploy VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = local.name
    Owner = local.user
  }
}

#Deploy the private subnets
resource "aws_subnet" "private_subnets" {
  for_each = var.private_subnets
  vpc_id = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, each.value)
  availability_zone = local.azs[each.value - 1]

  tags = {
    Name = local.name
    Owner = local.user
  }
}

#Deploy the public subnets
resource "aws_subnet" "public_subnets" {
  for_each = var.public_subnets
  vpc_id = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, each.value + 100)
  availability_zone = local.azs[each.value - 1]
  map_public_ip_on_launch = true

  tags = {
    Name = local.name
    Owner = local.user
  }
}

#Create route tables for public and private subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    Name = local.name
    Owner = local.user
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id     = aws_internet_gateway.internet_gateway.id
    #nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name = local.name
    Owner = local.user
  }
}

#Create route table associations
resource "aws_route_table_association" "public" {
  depends_on = [aws_subnet.public_subnets]
  route_table_id = aws_route_table.public_route_table.id
  for_each = aws_subnet.public_subnets
  subnet_id = each.value.id
}

resource "aws_route_table_association" "private" {
  depends_on = [aws_subnet.private_subnets]
  route_table_id = aws_route_table.private_route_table.id
  for_each = aws_subnet.private_subnets
  subnet_id = each.value.id
}

#Create Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = local.name
    Owner = local.user
  }
}