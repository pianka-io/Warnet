resource "aws_instance" "gamenet" {
  ami                         = "ami-0efc43a4067fe9a3e"
  instance_type               = "t2.medium"
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  associate_public_ip_address = true
  key_name                    = "warnet"

  tags = {
    Name = "warnet"
  }
}
