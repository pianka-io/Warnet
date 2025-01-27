variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
}

variable "vpc_name" {
  description = "Name for the VPC"
  type        = string
}

variable "db_cidr" {
  description = "CIDR block for database access"
  type        = string
}

variable "peer_routes" {
  description = "A map of peer routes with destination CIDR blocks and peering connection IDs"
  type = map(object({
    destination_cidr_block    = string
    vpc_peering_connection_id = string
  }))
  default = {}
}
