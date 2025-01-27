resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-public-route-table"
  }
}

resource "aws_route" "peer_routes" {
  for_each = var.peer_routes

  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = each.value.destination_cidr_block
  vpc_peering_connection_id = each.value.vpc_peering_connection_id
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-subnet"
  }
}

resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "ec2" {
  name   = "ec2"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ec2-security-group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ec2_ping" {
  security_group_id = aws_security_group.ec2.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = -1
  ip_protocol       = "icmp"
  to_port           = -1
}

resource "aws_vpc_security_group_ingress_rule" "ec2_ssh" {
  cidr_ipv4         = "0.0.0.0/0"
  security_group_id = aws_security_group.ec2.id
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "ec2_bncs" {
  security_group_id = aws_security_group.ec2.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 6112
  ip_protocol       = "tcp"
  to_port           = 6112
}

resource "aws_vpc_security_group_egress_rule" "ec2_all" {
  security_group_id = aws_security_group.ec2.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}