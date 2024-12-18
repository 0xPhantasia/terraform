#Retrieve 3 available AZs
data "aws_availability_zones" "available" {}
data "aws_region" "current" {}
locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

#Deploy VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
}

#Deploy the private subnets
resource "aws_subnet" "private_subnets" {
  for_each          = zipmap(range(0, 3), data.aws_availability_zones.available.names)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.key)
  availability_zone = each.value
}

#Deploy the public subnets
resource "aws_subnet" "public_subnets" {
  for_each                = zipmap(range(0, 3), data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, each.key + 100)
  availability_zone       = each.value
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
    cidr_block     = "0.0.0.0/0"
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
  domain = "vpc"
}

#Create NAT gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip.allocation_id
  subnet_id     = values(aws_subnet.public_subnets)[0].id
  depends_on    = [aws_internet_gateway.internet_gateway]
}

