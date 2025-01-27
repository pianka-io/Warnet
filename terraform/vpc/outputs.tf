output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_id" {
  value = aws_subnet.main.id
}

output "ec2_security_group_id" {
  value = aws_security_group.ec2.id
}
