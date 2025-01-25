resource "aws_instance" "warnet" {
  ami                         = "ami-0b824312e8ea0a8c4"
  instance_type               = "t2.xlarge"
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  associate_public_ip_address = true
  key_name                    = "warnet"

  tags = {
    Name = "warnet"
  }
}
