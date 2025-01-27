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
