# VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_block
  enable_dns_hostnames = true
  enable_dns_support = true
}

# Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
}

# Public Routes (associated with internet gateway)
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "public_route" {
  route_table_id = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.internet_gateway.id
}

# Private Routes (associated with NAT Gateway so worker nodes can access internet)
resource "aws_route_table" "private_route_table_1" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "private_route_table_2" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "private_route_1" {
  route_table_id = aws_route_table.private_route_table_1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat_gateway_1.id
}

resource "aws_route" "private_route_2" {
  route_table_id = aws_route_table.private_route_table_2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat_gateway_2.id
}

resource "aws_eip" "nat_gateway_eip_1" {
  vpc = true
}

resource "aws_eip" "nat_gateway_eip_2" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway_1" {
  allocation_id = aws_eip.nat_gateway_eip_1.id
  subnet_id = aws_subnet.private_subnet_1_block.id
}

resource "aws_nat_gateway" "nat_gateway_2" {
  allocation_id = aws_eip.nat_gateway_eip_2.id
  subnet_id = aws_subnet.private_subnet_2_block.id
}

# Route table associations
resource "aws_route_table_association" "public_subnet_1_route_table_association" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id = aws_subnet.public_subnet_1_block.id
}

resource "aws_route_table_association" "public_subnet_2_route_table_association" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id = aws_subnet.public_subnet_2_block.id
}

resource "aws_route_table_association" "private_subnet_1_route_table_association" {
  route_table_id = aws_route_table.private_route_table_1.id
  subnet_id = aws_subnet.private_subnet_1_block.id
}

resource "aws_route_table_association" "private_subnet_2_route_table_association" {
  route_table_id = aws_route_table.private_route_table_2.id
  subnet_id = aws_subnet.private_subnet_2_block.id
}

# Public subnets for load balancers
data "aws_availability_zones" "available_zones" {
  state = "available"
}

resource "aws_subnet" "public_subnet_1_block" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.public_subnet_1_block
  availability_zone = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch = true
  // Tagging requirements: https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html
  tags = {
    Name = "Public Subnet 1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_subnet" "public_subnet_2_block" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.public_subnet_2_block
  availability_zone = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch = true
  // Tagging requirements: https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html
  tags = {
    Name = "Public Subnet 2"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb" = 1
  }
}

# Private subnets for worker nodes
resource "aws_subnet" "private_subnet_1_block" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.private_subnet_1_block
  availability_zone = data.aws_availability_zones.available_zones.names[0]
  // Tagging requirements: https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html
  tags = {
    Name = "Private Subnet 1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_subnet" "private_subnet_2_block" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.private_subnet_2_block
  availability_zone = data.aws_availability_zones.available_zones.names[1]
  // Tagging requirements: https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html
  tags = {
    Name = "Private Subnet 2"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}

# Security Groups
resource "aws_security_group" "control_plane_security_group" {
  vpc_id = aws_vpc.vpc.id
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

# Outputs
output "subnet_ids" {
  value = [
    aws_subnet.private_subnet_1_block.id,
    aws_subnet.private_subnet_2_block.id,
    aws_subnet.public_subnet_1_block.id,
    aws_subnet.public_subnet_2_block.id
  ]
}

output "control_plane_security_group_id" {
  value = aws_security_group.control_plane_security_group.id
}

