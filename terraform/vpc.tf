module "virginia_vpc" {
  source      = "./vpc"
  region      = "us-east-1"
  vpc_cidr    = "10.0.0.0/16"
  subnet_cidr = "10.0.1.0/24"
  vpc_name    = "virginia"
  db_cidr     = "172.31.0.0/16"

  peer_routes = {
    ohio = {
      destination_cidr_block    = "172.31.0.0/16"
      vpc_peering_connection_id = "pcx-0099515777e64db6a"
    }
  }

  providers = {
    aws = aws.virginia
  }
}

module "california_vpc" {
  source      = "./vpc"
  region      = "us-west-1"
  vpc_cidr    = "10.1.0.0/16"
  subnet_cidr = "10.1.1.0/24"
  vpc_name    = "california"
  db_cidr     = "172.31.0.0/16"

  peer_routes = {
    ohio = {
      destination_cidr_block    = "172.31.0.0/16"
      vpc_peering_connection_id = "pcx-005c52f207644dc16"
    }
  }

  providers = {
    aws = aws.california
  }
}

module "mexico_vpc" {
  source      = "./vpc"
  region      = "mx-central-1"
  vpc_cidr    = "10.2.0.0/16"
  subnet_cidr = "10.2.1.0/24"
  vpc_name    = "mexico"
  db_cidr     = "172.31.0.0/16"

  peer_routes = {
    ohio = {
      destination_cidr_block    = "172.31.0.0/16"
      vpc_peering_connection_id = "pcx-042b781d39e6be7b1"
    }
  }

  providers = {
    aws = aws.mexico
  }
}
