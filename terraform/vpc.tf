/* NORAM */
module "virginia_vpc" {
  source      = "./vpc"
  hosted_zone_id = aws_route53_zone.war_pianka_io.zone_id
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
  hosted_zone_id = aws_route53_zone.war_pianka_io.zone_id
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
  hosted_zone_id = aws_route53_zone.war_pianka_io.zone_id
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
  hosted_zone_id = aws_route53_zone.war_pianka_io.zone_id
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
  hosted_zone_id = aws_route53_zone.war_pianka_io.zone_id
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
  hosted_zone_id = aws_route53_zone.war_pianka_io.zone_id
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
  hosted_zone_id = aws_route53_zone.war_pianka_io.zone_id
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
  hosted_zone_id = aws_route53_zone.war_pianka_io.zone_id
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
  hosted_zone_id = aws_route53_zone.war_pianka_io.zone_id
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
  hosted_zone_id = aws_route53_zone.war_pianka_io.zone_id
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

module "milan_vpc" {
  source      = "./vpc"
  hosted_zone_id = aws_route53_zone.war_pianka_io.zone_id
  region      = "eu-south-1"
  vpc_cidr    = "10.10.0.0/16"
  subnet_cidr = "10.10.1.0/24"
  vpc_name    = "milan"
  db_cidr     = "172.31.0.0/16"

  peer_routes = {
    ohio = {
      destination_cidr_block    = "172.31.0.0/16"
      vpc_peering_connection_id = "pcx-0c05fc662f79f7f12"
    }
  }

  providers = {
    aws = aws.milan
  }
}

module "paris_vpc" {
  source      = "./vpc"
  hosted_zone_id = aws_route53_zone.war_pianka_io.zone_id
  region      = "eu-west-3"
  vpc_cidr    = "10.11.0.0/16"
  subnet_cidr = "10.11.1.0/24"
  vpc_name    = "paris"
  db_cidr     = "172.31.0.0/16"

  peer_routes = {
    ohio = {
      destination_cidr_block    = "172.31.0.0/16"
      vpc_peering_connection_id = "pcx-03ffb80ca336f2168"
    }
  }

  providers = {
    aws = aws.paris
  }
}

module "spain_vpc" {
  source      = "./vpc"
  hosted_zone_id = aws_route53_zone.war_pianka_io.zone_id
  region      = "eu-south-2"
  vpc_cidr    = "10.12.0.0/16"
  subnet_cidr = "10.12.1.0/24"
  vpc_name    = "spain"
  db_cidr     = "172.31.0.0/16"

  peer_routes = {
    ohio = {
      destination_cidr_block    = "172.31.0.0/16"
      vpc_peering_connection_id = "pcx-0341b68c6de6b9861"
    }
  }

  providers = {
    aws = aws.spain
  }
}

module "stockholm_vpc" {
  source      = "./vpc"
  hosted_zone_id = aws_route53_zone.war_pianka_io.zone_id
  region      = "eu-north-1"
  vpc_cidr    = "10.13.0.0/16"
  subnet_cidr = "10.13.1.0/24"
  vpc_name    = "stockholm"
  db_cidr     = "172.31.0.0/16"

  peer_routes = {
    ohio = {
      destination_cidr_block    = "172.31.0.0/16"
      vpc_peering_connection_id = "pcx-0fddedecf228089df"
    }
  }

  providers = {
    aws = aws.stockholm
  }
}

module "zurich_vpc" {
  source      = "./vpc"
  hosted_zone_id = aws_route53_zone.war_pianka_io.zone_id
  region      = "eu-central-2"
  vpc_cidr    = "10.14.0.0/16"
  subnet_cidr = "10.14.1.0/24"
  vpc_name    = "zurich"
  db_cidr     = "172.31.0.0/16"

  peer_routes = {
    ohio = {
      destination_cidr_block    = "172.31.0.0/16"
      vpc_peering_connection_id = "pcx-05b75f0ee829cea50"
    }
  }

  providers = {
    aws = aws.zurich
  }
}

// middle east, africa, israel
module "bahrain_vpc" {
  source      = "./vpc"
  hosted_zone_id = aws_route53_zone.war_pianka_io.zone_id
  region      = "me-south-1"
  vpc_cidr    = "10.15.0.0/16"
  subnet_cidr = "10.15.1.0/24"
  vpc_name    = "bahrain"
  db_cidr     = "172.31.0.0/16"

  peer_routes = {
    ohio = {
      destination_cidr_block    = "172.31.0.0/16"
      vpc_peering_connection_id = "pcx-0b7ef9558bb39cd9b"
    }
  }

  providers = {
    aws = aws.bahrain
  }
}

module "uae_vpc" {
  source      = "./vpc"
  hosted_zone_id = aws_route53_zone.war_pianka_io.zone_id
  region      = "me-central-1"
  vpc_cidr    = "10.16.0.0/16"
  subnet_cidr = "10.16.1.0/24"
  vpc_name    = "uae"
  db_cidr     = "172.31.0.0/16"

  peer_routes = {
    ohio = {
      destination_cidr_block    = "172.31.0.0/16"
      vpc_peering_connection_id = "pcx-06dcafebb7a586fa0"
    }
  }

  providers = {
    aws = aws.uae
  }
}

module "tel_aviv_vpc" {
  source      = "./vpc"
  hosted_zone_id = aws_route53_zone.war_pianka_io.zone_id
  region      = "il-central-1"
  vpc_cidr    = "10.17.0.0/16"
  subnet_cidr = "10.17.1.0/24"
  vpc_name    = "tel_aviv"
  db_cidr     = "172.31.0.0/16"

  peer_routes = {
    ohio = {
      destination_cidr_block    = "172.31.0.0/16"
      vpc_peering_connection_id = "pcx-0e29f2b1d53fa2919"
    }
  }

  providers = {
    aws = aws.tel_aviv
  }
}

module "cape_town_vpc" {
  source      = "./vpc"
  hosted_zone_id = aws_route53_zone.war_pianka_io.zone_id
  region      = "af-south-1"
  vpc_cidr    = "10.18.0.0/16"
  subnet_cidr = "10.18.1.0/24"
  vpc_name    = "cape_town"
  db_cidr     = "172.31.0.0/16"

  peer_routes = {
    ohio = {
      destination_cidr_block    = "172.31.0.0/16"
      vpc_peering_connection_id = "pcx-0527fe12eb6d51ecb"
    }
  }

  providers = {
    aws = aws.cape_town
  }
}
