resource "aws_vpc" "virginia" {
  provider         = aws.virginia
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "virginia"
  }
}

resource "aws_subnet" "virginia" {
  provider   = aws.virginia
  vpc_id     = aws_vpc.virginia.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "virginia"
  }
}

resource "aws_vpc" "california" {
  provider         = aws.california
  cidr_block       = "10.1.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "california"
  }
}

resource "aws_subnet" "california" {
  provider   = aws.california
  vpc_id     = aws_vpc.california.id
  cidr_block = "10.1.1.0/24"

  tags = {
    Name = "california"
  }
}
