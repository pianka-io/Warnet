terraform {
  backend "s3" {
    bucket = "pianka-io-warnet-terraform"
    key    = "terraform.tfstate"
    region = "us-east-2"
  }
}

provider "aws" {
  region = "us-east-2"
}
