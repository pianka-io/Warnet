packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
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

variable "ami_name" {
  default = "warnet"
}

source "amazon-ebs" "baseline" {
  profile                     = "${var.profile}"
  region                      = "${var.region}"
  availability_zone	          = "${var.availability_zone}"
  vpc_id                      = "${var.vpc_id}"
  subnet_id                   = "${var.subnet_id}"
  ami_regions                 = [
    "us-east-2",
    "us-east-1",
    "us-west-1",
    "mx-central-1",
    "us-west-2",
    "ca-central-1",
    "ca-west-1",
    "sa-east-1",
    "eu-central-1",
    "eu-west-1",
    "eu-west-2",
    "eu-south-1",
    "eu-west-3",
    "eu-south-2",
    "eu-north-1",
    "eu-central-2",
    "me-south-1",
    "me-central-1",
    "il-central-1",
    "af-south-1"
  ]

  force_deregister            = true
  force_delete_snapshot       = true

  ami_name                    = "${var.ami_name}"
  instance_type               = "t2.xlarge"
  iam_instance_profile        = "certbot-instance-profile"
  source_ami                  = "ami-0eb070c40e6a142a3"
  ssh_username                = "ec2-user"
  encrypt_boot                = true
}

build {
  name    = "baseline"
  sources = ["source.amazon-ebs.baseline"]

  provisioner "ansible" {
    playbook_file   = "../ansible/nginx.yaml"
    use_proxy       = false

    extra_arguments = [
      "--extra-vars=${var.environment}"
    ]
  }

  provisioner "ansible" {
    playbook_file   = "../ansible/warnet.yaml"
    use_proxy       = false

    extra_arguments = [
      "--extra-vars=${var.environment}"
    ]
  }

  provisioner "ansible" {
    playbook_file   = "../ansible/iptables.yaml"
    use_proxy       = false

    extra_arguments = [
      "--extra-vars=${var.environment}"
    ]
  }

  post-processor "manifest" {
    output = "packer-manifest.json"
  }
}
