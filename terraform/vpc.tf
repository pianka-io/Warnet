/* NORAM */
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

module "oregon_vpc" {
  source      = "./vpc"
  region      = "us-west-2"
  vpc_cidr    = "10.3.0.0/16"
  subnet_cidr = "10.3.1.0/24"
  vpc_name    = "oregon"
  db_cidr     = "172.31.0.0/16"

  peer_routes = {
    ohio = {
      destination_cidr_block    = "172.31.0.0/16"
      vpc_peering_connection_id = "pcx-061ee5a6e52a5f131"
    }
  }

  providers = {
    aws = aws.oregon
  }
}

module "montreal_vpc" {
  source      = "./vpc"
  region      = "ca-central-1"
  vpc_cidr    = "10.4.0.0/16"
  subnet_cidr = "10.4.1.0/24"
  vpc_name    = "montreal"
  db_cidr     = "172.31.0.0/16"

  peer_routes = {
    ohio = {
      destination_cidr_block    = "172.31.0.0/16"
      vpc_peering_connection_id = "pcx-0dc5d6c9a22109620"
    }
  }

  providers = {
    aws = aws.montreal
  }
}

module "calgary_vpc" {
  source      = "./vpc"
  region      = "ca-west-1"
  vpc_cidr    = "10.5.0.0/16"
  subnet_cidr = "10.5.1.0/24"
  vpc_name    = "calgary"
  db_cidr     = "172.31.0.0/16"

  peer_routes = {
    ohio = {
      destination_cidr_block    = "172.31.0.0/16"
      vpc_peering_connection_id = "pcx-099ff12c6ef406605"
    }
  }

  providers = {
    aws = aws.calgary
  }
}

/* LATAM */
module "sao_paulo_vpc" {
  source      = "./vpc"
  region      = "sa-east-1"
  vpc_cidr    = "10.6.0.0/16"
  subnet_cidr = "10.6.1.0/24"
  vpc_name    = "sau_paulo"
  db_cidr     = "172.31.0.0/16"

  peer_routes = {
    ohio = {
      destination_cidr_block    = "172.31.0.0/16"
      vpc_peering_connection_id = "pcx-01460a2c5d7e54929"
    }
  }

  providers = {
    aws = aws.sao_paulo
  }
}

/* EMEA */
// europe
module "frankfurt_vpc" {
  source      = "./vpc"
  region      = "eu-central-1"
  vpc_cidr    = "10.7.0.0/16"
  subnet_cidr = "10.7.1.0/24"
  vpc_name    = "frankfurt"
  db_cidr     = "172.31.0.0/16"

  peer_routes = {
    ohio = {
      destination_cidr_block    = "172.31.0.0/16"
      vpc_peering_connection_id = "pcx-09d1508817a37385b"
    }
  }

  providers = {
    aws = aws.frankfurt
  }
}

module "ireland_vpc" {
  source      = "./vpc"
  region      = "eu-west-1"
  vpc_cidr    = "10.8.0.0/16"
  subnet_cidr = "10.8.1.0/24"
  vpc_name    = "ireland"
  db_cidr     = "172.31.0.0/16"

  peer_routes = {
    ohio = {
      destination_cidr_block    = "172.31.0.0/16"
      vpc_peering_connection_id = "pcx-0ab2d03b7470b6d51"
    }
  }

  providers = {
    aws = aws.ireland
  }
}

module "london_vpc" {
  source      = "./vpc"
  region      = "eu-west-2"
  vpc_cidr    = "10.9.0.0/16"
  subnet_cidr = "10.9.1.0/24"
  vpc_name    = "london"
  db_cidr     = "172.31.0.0/16"

  peer_routes = {
    ohio = {
      destination_cidr_block    = "172.31.0.0/16"
      vpc_peering_connection_id = "pcx-009d105bcfdc94101"
    }
  }

  providers = {
    aws = aws.london
  }
}
