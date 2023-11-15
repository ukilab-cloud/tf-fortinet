##############################################################################################################
# TRANSIT GATEWAY
##############################################################################################################
resource "aws_ec2_transit_gateway" "TGW-XAZ" {
  description                     = "Transit Gateway with 3 VPCs. 2 subnets in each."
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags = {
    Name     = "${var.tag_name_prefix}-tgw"
    scenario = var.scenario
  }
}

# Route Tables
resource "aws_ec2_transit_gateway_route_table" "TGW-spoke-rt" {
  depends_on         = [aws_ec2_transit_gateway.TGW-XAZ]
  transit_gateway_id = aws_ec2_transit_gateway.TGW-XAZ.id
  tags = {
    Name     = "${var.tag_name_prefix}-tgw-spokes-rt"
    scenario = var.scenario
  }
}

resource "aws_ec2_transit_gateway_route_table" "TGW-fortinet-rt" {
  depends_on         = [aws_ec2_transit_gateway.TGW-XAZ]
  transit_gateway_id = aws_ec2_transit_gateway.TGW-XAZ.id
  tags = {
    Name     = "${var.tag_name_prefix}-tgw-fortinet-rt"
    scenario = var.scenario
  }
}

# TGW routes
resource "aws_ec2_transit_gateway_route" "spokes_default" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-fortinet.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW-spoke-rt.id
}

# Route Tables Associations
resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-vpc-spoke-a-assoc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-att-spoke-vpc-a.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW-spoke-rt.id
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-vpc-spoke2-assoc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-att-spoke-vpc-b.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW-spoke-rt.id
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-vpc_fortinet" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-fortinet.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW-fortinet-rt.id
}

# Route Tables Propagations
## This section defines which VPCs will be routed from each Route Table created in the Transit Gateway

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-prp-spoke-a" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-att-spoke-vpc-a.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW-fortinet-rt.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-prp-spoke-b" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-att-spoke-vpc-b.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW-fortinet-rt.id
}