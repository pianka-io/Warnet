resource "aws_route" "peer_connection_to_virginia" {
  route_table_id            = "rtb-0b5cd8ca03abaea76" # Ohio
  destination_cidr_block    = "10.0.0.0/16"           # Virginia
  vpc_peering_connection_id = "pcx-0099515777e64db6a" # Virginia
}

resource "aws_route" "peer_connection_to_california" {
  route_table_id            = "rtb-0b5cd8ca03abaea76" # Ohio
  destination_cidr_block    = "10.1.0.0/16"           # California
  vpc_peering_connection_id = "pcx-005c52f207644dc16" # California
}

resource "aws_route" "peer_connection_to_mexico" {
  route_table_id            = "rtb-0b5cd8ca03abaea76" # Ohio
  destination_cidr_block    = "10.2.0.0/16"           # Mexico
  vpc_peering_connection_id = "pcx-042b781d39e6be7b1" # Mexico
}

resource "aws_route" "peer_connection_to_oregon" {
  route_table_id            = "rtb-0b5cd8ca03abaea76" # Ohio
  destination_cidr_block    = "10.3.0.0/16"           # Oregon
  vpc_peering_connection_id = "pcx-061ee5a6e52a5f131" # Oregon
}

resource "aws_route" "peer_connection_to_montreal" {
  route_table_id            = "rtb-0b5cd8ca03abaea76" # Ohio
  destination_cidr_block    = "10.4.0.0/16"           # Montreal
  vpc_peering_connection_id = "pcx-0dc5d6c9a22109620" # Montreal
}

resource "aws_route" "peer_connection_to_calgary" {
  route_table_id            = "rtb-0b5cd8ca03abaea76" # Ohio
  destination_cidr_block    = "10.5.0.0/16"           # Calgary
  vpc_peering_connection_id = "pcx-099ff12c6ef406605" # Calgary
}

resource "aws_route" "peer_connection_to_sao_paulo" {
  route_table_id            = "rtb-0b5cd8ca03abaea76" # Ohio
  destination_cidr_block    = "10.6.0.0/16"           # Sao Paulo
  vpc_peering_connection_id = "pcx-01460a2c5d7e54929" # Sao Paulo
}

resource "aws_route" "peer_connection_to_frankfurt" {
  route_table_id            = "rtb-0b5cd8ca03abaea76" # Ohio
  destination_cidr_block    = "10.7.0.0/16"           # Frankfurt
  vpc_peering_connection_id = "pcx-09d1508817a37385b" # Frankfurt
}

resource "aws_route" "peer_connection_to_ireland" {
  route_table_id            = "rtb-0b5cd8ca03abaea76" # Ohio
  destination_cidr_block    = "10.8.0.0/16"           # Ireland
  vpc_peering_connection_id = "pcx-0ab2d03b7470b6d51" # Ireland
}

resource "aws_route" "peer_connection_to_london" {
  route_table_id            = "rtb-0b5cd8ca03abaea76" # Ohio
  destination_cidr_block    = "10.9.0.0/16"           # London
  vpc_peering_connection_id = "pcx-009d105bcfdc94101" # London
}

resource "aws_route" "peer_connection_to_milan" {
  route_table_id            = "rtb-0b5cd8ca03abaea76" # Ohio
  destination_cidr_block    = "10.10.0.0/16"          # Milan
  vpc_peering_connection_id = "pcx-0c05fc662f79f7f12" # Milan
}

resource "aws_route" "peer_connection_to_paris" {
  route_table_id            = "rtb-0b5cd8ca03abaea76" # Ohio
  destination_cidr_block    = "10.11.0.0/16"          # Paris
  vpc_peering_connection_id = "pcx-03ffb80ca336f2168" # Paris
}

resource "aws_route" "peer_connection_to_spain" {
  route_table_id            = "rtb-0b5cd8ca03abaea76" # Ohio
  destination_cidr_block    = "10.12.0.0/16"          # Spain
  vpc_peering_connection_id = "pcx-0341b68c6de6b9861" # Spain
}

resource "aws_route" "peer_connection_to_stockholm" {
  route_table_id            = "rtb-0b5cd8ca03abaea76" # Ohio
  destination_cidr_block    = "10.13.0.0/16"          # Stockholm
  vpc_peering_connection_id = "pcx-0fddedecf228089df" # Stockholm
}

resource "aws_route" "peer_connection_to_zurich" {
  route_table_id            = "rtb-0b5cd8ca03abaea76" # Ohio
  destination_cidr_block    = "10.14.0.0/16"          # Zurich
  vpc_peering_connection_id = "pcx-05b75f0ee829cea50" # Zurich
}

resource "aws_route" "peer_connection_to_bahrain" {
  route_table_id            = "rtb-0b5cd8ca03abaea76" # Ohio
  destination_cidr_block    = "10.15.0.0/16"          # Zurich
  vpc_peering_connection_id = "pcx-0b7ef9558bb39cd9b" # Zurich
}

resource "aws_route" "peer_connection_to_uae" {
  route_table_id            = "rtb-0b5cd8ca03abaea76" # Ohio
  destination_cidr_block    = "10.16.0.0/16"          # Zurich
  vpc_peering_connection_id = "pcx-06dcafebb7a586fa0" # Zurich
}

resource "aws_route" "peer_connection_to_tel_aviv" {
  route_table_id            = "rtb-0b5cd8ca03abaea76" # Ohio
  destination_cidr_block    = "10.17.0.0/16"          # Zurich
  vpc_peering_connection_id = "pcx-0e29f2b1d53fa2919" # Zurich
}

resource "aws_route" "peer_connection_to_cape_town" {
  route_table_id            = "rtb-0b5cd8ca03abaea76" # Ohio
  destination_cidr_block    = "10.18.0.0/16"          # Zurich
  vpc_peering_connection_id = "pcx-0527fe12eb6d51ecb" # Zurich
}
