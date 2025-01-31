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

provider "aws" {
  alias = "mexico"
  region = "mx-central-1"
}

provider "aws" {
  alias = "oregon"
  region = "us-west-2"
}

provider "aws" {
  alias = "montreal"
  region = "ca-central-1"
}

provider "aws" {
  alias = "calgary"
  region = "ca-west-1"
}

provider "aws" {
  alias = "sao_paulo"
  region = "sa-east-1"
}
