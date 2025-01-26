resource "aws_security_group" "ec2" {
  name        = "ec2"
  vpc_id      = "vpc-06e29de4a84bc82a4"

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_security_group" "rds" {
  name        = "rds"
  vpc_id      = "vpc-06e29de4a84bc82a4"

  tags = {
    Name = "allow_tls"
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
  security_group_id = aws_security_group.ec2.id
  cidr_ipv4         = "47.20.130.49/32"
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

resource "aws_vpc_security_group_egress_rule" "ec2_rds" {
  security_group_id = aws_security_group.ec2.id
  referenced_security_group_id = aws_security_group.rds.id
  from_port   = 3306
  ip_protocol = "tcp"
  to_port     = 3306
}

resource "aws_vpc_security_group_egress_rule" "ec2_all" {
  security_group_id = aws_security_group.ec2.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "rds_ec2" {
  security_group_id = aws_security_group.rds.id
  referenced_security_group_id = aws_security_group.ec2.id
  from_port         = 3306
  ip_protocol       = "tcp"
  to_port           = 3306
}
