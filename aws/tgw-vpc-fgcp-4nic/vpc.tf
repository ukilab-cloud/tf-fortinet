##############################################################################################################
# VPC FORTINET
##############################################################################################################
resource "aws_vpc" "vpc_fortinet" {
  cidr_block           = var.fortinet_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.tag_name_prefix}-vpc_fortinet"
  }
}

# IGW
resource "aws_internet_gateway" "igw_fortinet" {
  vpc_id = aws_vpc.vpc_fortinet.id
  tags = {
    Name = "${var.tag_name_prefix}-vpc-fortinet-igw"
  }
}

# Subnets
resource "aws_subnet" "private_a_subnet" {
  vpc_id            = aws_vpc.vpc_fortinet.id
  cidr_block        = var.fortinet_vpc_private_a_subnet_cidr
  availability_zone = var.availability_zone1
  tags = {
    Name = "${var.tag_name_prefix}-vpc-fortinet-private-a-subnet"
  }
}

resource "aws_subnet" "private_b_subnet" {
  vpc_id            = aws_vpc.vpc_fortinet.id
  cidr_block        = var.fortinet_vpc_private_b_subnet_cidr
  availability_zone = var.availability_zone2
  tags = {
    Name = "${var.tag_name_prefix}-vpc-fortinet-private-b-subnet"
  }
}

resource "aws_subnet" "public_a_subnet" {
  vpc_id            = aws_vpc.vpc_fortinet.id
  cidr_block        = var.fortinet_vpc_public_a_subnet_cidr
  availability_zone = var.availability_zone1
  tags = {
    Name = "${var.tag_name_prefix}-vpc-fortinet-public-a-subnet"
  }
}

resource "aws_subnet" "public_b_subnet" {
  vpc_id            = aws_vpc.vpc_fortinet.id
  cidr_block        = var.fortinet_vpc_public_b_subnet_cidr
  availability_zone = var.availability_zone2
  tags = {
    Name = "${var.tag_name_prefix}-vpc-fortinet-public-b-subnet"
  }
}

resource "aws_subnet" "transit_a_subnet" {
  vpc_id            = aws_vpc.vpc_fortinet.id
  cidr_block        = var.fortinet_vpc_transit_a_subnet_cidr
  availability_zone = var.availability_zone1
  tags = {
    Name = "${var.tag_name_prefix}-vpc-fortinet-transit-a-subnet"
  }
}

resource "aws_subnet" "transit_b_subnet" {
  vpc_id            = aws_vpc.vpc_fortinet.id
  cidr_block        = var.fortinet_vpc_transit_b_subnet_cidr
  availability_zone = var.availability_zone2
  tags = {
    Name = "${var.tag_name_prefix}-vpc-fortinet-transit-b-subnet"
  }
}

resource "aws_subnet" "hasync_a_subnet" {
  vpc_id            = aws_vpc.vpc_fortinet.id
  cidr_block        = var.fortinet_vpc_hasync_a_subnet_cidr
  availability_zone = var.availability_zone1
  tags = {
    Name = "${var.tag_name_prefix}-vpc-fortinet-hasync-a-subnet"
  }
}

resource "aws_subnet" "hasync_b_subnet" {
  vpc_id            = aws_vpc.vpc_fortinet.id
  cidr_block        = var.fortinet_vpc_hasync_b_subnet_cidr
  availability_zone = var.availability_zone2
  tags = {
    Name = "${var.tag_name_prefix}-vpc-fortinet-hasync-b-subnet"
  }
}

resource "aws_subnet" "mgmt_a_subnet" {
  vpc_id            = aws_vpc.vpc_fortinet.id
  cidr_block        = var.fortinet_vpc_mgmt_a_subnet_cidr
  availability_zone = var.availability_zone1
  tags = {
    Name = "${var.tag_name_prefix}-vpc-fortinet-mgmt-a-subnet"
  }
}

resource "aws_subnet" "mgmt_b_subnet" {
  vpc_id            = aws_vpc.vpc_fortinet.id
  cidr_block        = var.fortinet_vpc_mgmt_b_subnet_cidr
  availability_zone = var.availability_zone2
  tags = {
    Name = "${var.tag_name_prefix}-vpc-fortinet-mgmt-b-subnet"
  }
}

# Routes
resource "aws_route_table" "fortinet_public_rt" {
  vpc_id = aws_vpc.vpc_fortinet.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_fortinet.id
  }
  tags = {
    Name = "${var.tag_name_prefix}-vpc-fortinet-public-rt"
  }
}

resource "aws_route_table" "fortinet_private_rt" {
  vpc_id = aws_vpc.vpc_fortinet.id  
  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.TGW-XAZ.id
  }
  tags = {
    Name = "${var.tag_name_prefix}-vpc-fortinet-private-rt"
  }
}

### NOTE - Route Table for Fortigate ENI (Transit Route Table entry) moved to 
### fortigate.tf so infrastructure can be deployed without the FortiGates being present.

resource "aws_route_table" "fortinet_hasync_rt" {
  vpc_id = aws_vpc.vpc_fortinet.id
  tags = {
    Name = "${var.tag_name_prefix}-vpc-fortinet-hasync-rt"
  }
}

resource "aws_route_table" "fortinet_mgmt_rt" {
  vpc_id = aws_vpc.vpc_fortinet.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_fortinet.id
  }
  tags = {
    Name = "${var.tag_name_prefix}-vpc-fortinet-mgmt-rt"
  }
}

# Route tables associations
resource "aws_route_table_association" "public_a_rt_association" {
  subnet_id      = aws_subnet.public_a_subnet.id
  route_table_id = aws_route_table.fortinet_public_rt.id
}

resource "aws_route_table_association" "public_b_rt_association" {
  subnet_id      = aws_subnet.public_b_subnet.id
  route_table_id = aws_route_table.fortinet_public_rt.id
}

resource "aws_route_table_association" "private_a_rt_association" {
  subnet_id      = aws_subnet.private_a_subnet.id
  route_table_id = aws_route_table.fortinet_private_rt.id
}

resource "aws_route_table_association" "private_b_rt_association" {
  subnet_id      = aws_subnet.private_b_subnet.id
  route_table_id = aws_route_table.fortinet_private_rt.id
}

resource "aws_route_table_association" "transit_a_rt_association" {
  subnet_id      = aws_subnet.transit_a_subnet.id
  route_table_id = aws_route_table.fortinet_transit_rt.id
}

resource "aws_route_table_association" "transit_b_rt_association" {
  subnet_id      = aws_subnet.transit_b_subnet.id
  route_table_id = aws_route_table.fortinet_transit_rt.id
}

resource "aws_route_table_association" "hasync_a_rt_association" {
  subnet_id      = aws_subnet.hasync_a_subnet.id
  route_table_id = aws_route_table.fortinet_hasync_rt.id
}

resource "aws_route_table_association" "hasync_b_rt_association" {
  subnet_id      = aws_subnet.hasync_b_subnet.id
  route_table_id = aws_route_table.fortinet_hasync_rt.id
}

resource "aws_route_table_association" "mgmt_a_rt_association" {
  subnet_id      = aws_subnet.mgmt_a_subnet.id
  route_table_id = aws_route_table.fortinet_mgmt_rt.id
}

resource "aws_route_table_association" "mgmt_b_rt_association" {
  subnet_id      = aws_subnet.mgmt_b_subnet.id
  route_table_id = aws_route_table.fortinet_mgmt_rt.id
}

# Attachment to TGW
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-att-vpc-fortinet" {
  subnet_ids                                      = [aws_subnet.transit_a_subnet.id, aws_subnet.transit_b_subnet.id]
  transit_gateway_id                              = aws_ec2_transit_gateway.TGW-XAZ.id
  vpc_id                                          = aws_vpc.vpc_fortinet.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name     = "tgw-att-vpc_fortinet"
    scenario = var.scenario
  }
  depends_on = [aws_ec2_transit_gateway.TGW-XAZ]
}

#################################
# VPC SPOKE1 - Availability Zone1
#################################

resource "aws_vpc" "spoke_vpc_a" {
  cidr_block = var.spoke_vpc_a_cidr

  tags = {
    Name     = "${var.tag_name_prefix}-vpc-spoke-a"
    scenario = var.scenario
  }
}

### Subnets

resource "aws_subnet" "spoke_vpc_a_workload_a_subnet" {
  vpc_id            = aws_vpc.spoke_vpc_a.id
  cidr_block        = var.spoke_vpc_a_workload_a_subnet_cidr
  availability_zone = var.availability_zone1

  tags = {
    Name = "${aws_vpc.spoke_vpc_a.tags.Name}-workload-a"
  }
}

resource "aws_subnet" "spoke_vpc_a_transit_a_subnet" {
  vpc_id            = aws_vpc.spoke_vpc_a.id
  cidr_block        = var.spoke_vpc_a_transit_a_subnet_cidr
  availability_zone = var.availability_zone1

  tags = {
    Name = "${aws_vpc.spoke_vpc_a.tags.Name}-transit-a"
  }
}

### Routes

resource "aws_route_table" "spoke-vpc-a-workload-a-rt" {
  vpc_id = aws_vpc.spoke_vpc_a.id

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.TGW-XAZ.id
  }

  tags = {
    Name     = "${var.tag_name_prefix}-vpc-spoke-a-workload-a-rt"
    scenario = var.scenario
  }
  depends_on = [aws_ec2_transit_gateway.TGW-XAZ]
}

resource "aws_route_table" "spoke-vpc-a-transit-a-rt" {
  vpc_id = aws_vpc.spoke_vpc_a.id

  tags = {
    Name     = "${var.tag_name_prefix}-vpc-spoke-a-transit-a-rt"
    scenario = var.scenario
  }
  depends_on = [aws_ec2_transit_gateway.TGW-XAZ]
}

### Route table associations

resource "aws_route_table_association" "spoke_a_workload_a_rt_association" {
  subnet_id      = aws_subnet.spoke_vpc_a_workload_a_subnet.id
  route_table_id = aws_route_table.spoke-vpc-a-workload-a-rt.id
}

resource "aws_route_table_association" "spoke_a_transit_a_rt_association" {
  subnet_id      = aws_subnet.spoke_vpc_a_transit_a_subnet.id
  route_table_id = aws_route_table.spoke-vpc-a-transit-a-rt.id
}

### TGW - VPC Attachment

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-att-spoke-vpc-a" {
  subnet_ids                                      = [aws_subnet.spoke_vpc_a_transit_a_subnet.id]
  transit_gateway_id                              = aws_ec2_transit_gateway.TGW-XAZ.id
  vpc_id                                          = aws_vpc.spoke_vpc_a.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name     = "tgw-att-spoke-vpc-a"
    scenario = var.scenario
  }
  depends_on = [aws_ec2_transit_gateway.TGW-XAZ]
}

###################################
# VPC SPOKE B - Availability Zone 2
###################################

resource "aws_vpc" "spoke_vpc_b" {
  cidr_block = var.spoke_vpc_b_cidr

  tags = {
    Name     = "${var.tag_name_prefix}-vpc-spoke-b"
    scenario = var.scenario
  }
}

### Subnets

resource "aws_subnet" "spoke_vpc_b_workload_b_subnet" {
  vpc_id            = aws_vpc.spoke_vpc_b.id
  cidr_block        = var.spoke_vpc_b_workload_b_subnet_cidr
  availability_zone = var.availability_zone2

  tags = {
    Name = "${aws_vpc.spoke_vpc_b.tags.Name}-workload-b"
  }
}

resource "aws_subnet" "spoke_vpc_b_transit_b_subnet" {
  vpc_id            = aws_vpc.spoke_vpc_b.id
  cidr_block        = var.spoke_vpc_b_transit_b_subnet_cidr
  availability_zone = var.availability_zone2

  tags = {
    Name = "${aws_vpc.spoke_vpc_b.tags.Name}-transit-b"
  }
}

###  Routes

resource "aws_route_table" "spoke-vpc-b-workload-b-rt" {
  vpc_id = aws_vpc.spoke_vpc_b.id

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.TGW-XAZ.id
  }

  tags = {
    Name     = "${var.tag_name_prefix}-vpc-spoke-b-workload-b-rt"
    scenario = var.scenario
  }
  depends_on = [aws_ec2_transit_gateway.TGW-XAZ]
}

resource "aws_route_table" "spoke-vpc-b-transit-b-rt" {
  vpc_id = aws_vpc.spoke_vpc_b.id

  tags = {
    Name     = "${var.tag_name_prefix}-vpc-spoke-b-transit-b-rt"
    scenario = var.scenario
  }
  depends_on = [aws_ec2_transit_gateway.TGW-XAZ]
}

### Route table associations

resource "aws_route_table_association" "spoke_b_workload_b_rt_association" {
  subnet_id      = aws_subnet.spoke_vpc_b_workload_b_subnet.id
  route_table_id = aws_route_table.spoke-vpc-b-workload-b-rt.id
}

resource "aws_route_table_association" "spoke_b_transit_b_rt_association" {
  subnet_id      = aws_subnet.spoke_vpc_b_transit_b_subnet.id
  route_table_id = aws_route_table.spoke-vpc-b-transit-b-rt.id
}

# TGW - VPC Attachment

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-att-spoke-vpc-b" {
  subnet_ids                                      = [aws_subnet.spoke_vpc_b_transit_b_subnet.id]
  transit_gateway_id                              = aws_ec2_transit_gateway.TGW-XAZ.id
  vpc_id                                          = aws_vpc.spoke_vpc_b.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name     = "tgw-att-spoke-vpc-b"
    scenario = var.scenario
  }
  depends_on = [aws_ec2_transit_gateway.TGW-XAZ]
}
