packer {
  required_plugins {
    aws-baseline = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "environment" {
  type = string
}

variable "profile" {
  type = string
}

variable "account" {
  type = string
}

variable "region" {
  type = string
}

variable "availability_zone" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

source "amazon-ebs" "baseline" {
  profile                     = "${var.profile}"
  region                      = "${var.region}"
  availability_zone	          = "${var.availability_zone}"
  vpc_id                      = "${var.vpc_id}"
  subnet_id                   = "${var.subnet_id}"
#  ssh_interface               = "private_ip"

  force_deregister            = true
  force_delete_snapshot       = true

  ami_name                    = "warnet"
  instance_type               = "t2.xlarge"
  source_ami                  = "ami-0eb070c40e6a142a3"
  ssh_username                = "ec2-user"
  encrypt_boot                = true
}

build {
  name                  = "baseline"
  sources               = [
    "source.amazon-ebs.baseline"
  ]

  provisioner "ansible" {
    playbook_file   = "../ansible/warnet.yaml"
    use_proxy       = false

    extra_arguments = [
      "--extra-vars=${var.environment}"
    ]
  }
}
