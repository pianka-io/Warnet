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

provider "aws" {
  alias = "virginia"
  region = "us-east-1"
}

provider "aws" {
  alias = "california"
  region = "us-west-1"
}
