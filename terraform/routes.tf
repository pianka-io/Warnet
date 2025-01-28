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
