######################################
### FortiGate Active/Passive Setup ###
######################################

### Security Groups

resource "aws_security_group" "NSG-vpc-fortinet-ssh-icmp-https" {
  name        = "NSG-vpc-fortinet-ssh-icmp-https"
  description = "Allow SSH, HTTPS and ICMP traffic"
  vpc_id      = aws_vpc.vpc_fortinet.id

  ingress {
    description = "Allow remote access to FGT"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name     = "${var.tag_name_prefix}-vpc-fortinet-ssh-icmp-https"
    scenario = var.scenario
  }
}

### VPC Endpoint for HA

resource "aws_vpc_endpoint" "endpoint" {
  vpc_id            = aws_vpc.vpc_fortinet.id
  service_name      = "com.amazonaws.${var.region}.ec2"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.NSG-vpc-fortinet-ssh-icmp-https.id,
  ]

  private_dns_enabled = true
  subnet_ids          = [aws_subnet.mgmt_a_subnet.id, aws_subnet.mgmt_b_subnet.id]
  tags = {
    Name = "${var.tag_name_prefix}-vpc-endpoint-fgha"
  }
}


### Determine FG AMI baed on variables and data query

locals{
  fortigate_ami_regex_ver = join("\\.",split(".","${var.fos_version}"))
}

data "aws_ami" "fortigate_ami" {
    most_recent = true
    name_regex  = local.fortigate_ami_regex_ver

    filter {
        name   = "name"
        values = var.fos_license_type == "payg" ? ["FortiGate-VM64-AWSONDEMAND*"] : ["FortiGate-VM64-AWS *"]
    }
    
    filter {
      name   = "architecture"
      values = ["${var.fos_architecture}"]
  
    }
    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["aws-marketplace"]
}

### IAM Role and Instance Profile for use by FGCP HA Failover Mechanism

resource "aws_iam_instance_profile" "fortigate_profile" {
  name = "fortigate_profile"
  role = aws_iam_role.fortigate_role.name
}

data "aws_iam_policy_document" "fortigate_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "fortigate_role" {
  name               = "fortigate_role"
  assume_role_policy = data.aws_iam_policy_document.fortigate_assume_role.json
}

data "aws_iam_policy_document" "fortigate_policy_document" {
  statement {
    effect    = "Allow"
    actions   = [
      "ec2:Describe*",
      "ec2:AssociateAddress",
      "ec2:AssignPrivateIpAddresses",
      "ec2:UnassignPrivateIpAddresses",
      "ec2:ReplaceRoute"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "fortigate_policy" {
  name        = "fortigate_policy"
  description = "fortigate Policy"
  policy      = data.aws_iam_policy_document.fortigate_policy_document.json
}

resource "aws_iam_role_policy_attachment" "fortigate-attach" {
  role       = aws_iam_role.fortigate_role.name
  policy_arn = aws_iam_policy.fortigate_policy.arn
}

### Create all the eni interfaces

resource "aws_network_interface" "fgta-public-a-eni" {
  subnet_id         = aws_subnet.public_a_subnet.id
  security_groups   = [aws_security_group.NSG-vpc-fortinet-ssh-icmp-https.id]
  private_ips       = [cidrhost(var.fortinet_vpc_public_a_subnet_cidr, 10)]
  source_dest_check = false
  tags = {
    Name = "${var.tag_name_prefix}-fgta-public-eni"
  }
}

resource "aws_network_interface" "fgtb-public-b-eni" {
  subnet_id         = aws_subnet.public_b_subnet.id
  security_groups   = [aws_security_group.NSG-vpc-fortinet-ssh-icmp-https.id]
  private_ips       = [cidrhost(var.fortinet_vpc_public_b_subnet_cidr, 10)]
  source_dest_check = false
  tags = {
    Name = "${var.tag_name_prefix}-fgtb-public-eni"
  }
}

resource "aws_network_interface" "fgta-private-a-eni" {
  subnet_id         = aws_subnet.private_a_subnet.id
  security_groups   = [aws_security_group.NSG-vpc-fortinet-ssh-icmp-https.id]
  private_ips       = [cidrhost(var.fortinet_vpc_private_a_subnet_cidr, 10)]
  source_dest_check = false
  tags = {
    Name = "${var.tag_name_prefix}-fgta-private-eni"
  }
}

resource "aws_network_interface" "fgtb-private-b-eni" {
  subnet_id         = aws_subnet.private_b_subnet.id
  security_groups   = [aws_security_group.NSG-vpc-fortinet-ssh-icmp-https.id]
  private_ips       = [cidrhost(var.fortinet_vpc_private_b_subnet_cidr, 10)]
  source_dest_check = false
  tags = {
    Name = "${var.tag_name_prefix}-fgtb-private-eni"
  }
}

resource "aws_network_interface" "fgta-hasync-a-eni" {
  subnet_id         = aws_subnet.hasync_a_subnet.id
  security_groups   = [aws_security_group.NSG-vpc-fortinet-ssh-icmp-https.id]
  private_ips       = [cidrhost(var.fortinet_vpc_hasync_a_subnet_cidr, 10)]
  source_dest_check = false
  tags = {
    Name = "${var.tag_name_prefix}-fgta-hasync-eni"
  }
}

resource "aws_network_interface" "fgtb-hasync-b-eni" {
  subnet_id         = aws_subnet.hasync_b_subnet.id
  security_groups   = [aws_security_group.NSG-vpc-fortinet-ssh-icmp-https.id]
  private_ips       = [cidrhost(var.fortinet_vpc_hasync_b_subnet_cidr, 10)]
  source_dest_check = false
  tags = {
    Name = "${var.tag_name_prefix}-fgtb-hasync-eni"
  }
}

resource "aws_network_interface" "fgta-mgmt-a-eni" {
  subnet_id         = aws_subnet.mgmt_a_subnet.id
  security_groups   = [aws_security_group.NSG-vpc-fortinet-ssh-icmp-https.id]
  private_ips       = [cidrhost(var.fortinet_vpc_mgmt_a_subnet_cidr, 10)]
  source_dest_check = false
  tags = {
    Name = "${var.tag_name_prefix}-fgta-mgmt-eni"
  }
}

resource "aws_network_interface" "fgtb-mgmt-b-eni" {
  subnet_id         = aws_subnet.mgmt_b_subnet.id
  security_groups   = [aws_security_group.NSG-vpc-fortinet-ssh-icmp-https.id]
  private_ips       = [cidrhost(var.fortinet_vpc_mgmt_b_subnet_cidr, 10)]
  source_dest_check = false
  tags = {
    Name = "${var.tag_name_prefix}-fgtb-mgmt-eni"
  }
}

### Comment Out/Remove EIPS once a secure mechanism of accessing the FortiGate
### Management interfaces is established - also remove outputs for these

resource "aws_eip" "eip-mgmt1" {
  depends_on        = [aws_instance.fgta]
  domain            = "vpc"
  network_interface = aws_network_interface.fgta-mgmt-a-eni.id
  tags = {
    Name = "${var.tag_name_prefix}-fgta-mgmt-eip"
  }
}

resource "aws_eip" "eip-mgmt2" {
  depends_on        = [aws_instance.fgtb]
  domain            = "vpc"
  network_interface = aws_network_interface.fgtb-mgmt-b-eni.id
  tags = {
    Name = "${var.tag_name_prefix}-fgtb-mgmt-eip"
  }
}

### Cluster EIP - moved between Fortigates during HA

resource "aws_eip" "eip-shared" {
  depends_on        = [aws_instance.fgta]
  domain            = "vpc"
  network_interface = aws_network_interface.fgta-public-a-eni.id
  tags = {
    Name = "${var.tag_name_prefix}-fgt-cluster-eip"
  }
}

### FortiGate Route Table entry for use by the FGCP Actice/Passive Mechanism

resource "aws_route_table" "fortinet_transit_rt" {
  vpc_id = aws_vpc.vpc_fortinet.id
  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_network_interface.fgta-private-a-eni.id
  }
  tags = {
    Name = "${var.tag_name_prefix}-vpc-fortinet-transit-rt"
  }
}

### FortiGate A - Userdata - Template Variable

data "template_file" "userdata_fgta" {
  template = "${file("${path.module}/fgt-userdata.tpl")}"
  vars = {
    fgt_id               = "FGT-A"
    type                 = "${var.fos_license_type}"
    license_file         = "${var.license}"
    fgt_public_ip        = join("/", [element(tolist(aws_network_interface.fgta-public-a-eni.private_ips), 0), cidrnetmask("${var.fortinet_vpc_public_a_subnet_cidr}")])
    fgt_private_ip       = join("/", [element(tolist(aws_network_interface.fgta-private-a-eni.private_ips), 0), cidrnetmask("${var.fortinet_vpc_private_a_subnet_cidr}")])
    fgt_hasync_ip        = join("/", [element(tolist(aws_network_interface.fgta-hasync-a-eni.private_ips), 0), cidrnetmask("${var.fortinet_vpc_hasync_a_subnet_cidr}")])
    fgt_mgmt_ip          = join("/", [element(tolist(aws_network_interface.fgta-mgmt-a-eni.private_ips), 0), cidrnetmask("${var.fortinet_vpc_mgmt_a_subnet_cidr}")])
    public_gw            = cidrhost(var.fortinet_vpc_public_a_subnet_cidr, 1)
    private_gw           = cidrhost(var.fortinet_vpc_private_a_subnet_cidr, 1)
    spoke1_cidr          = var.spoke_vpc_a_cidr
    spoke2_cidr          = var.spoke_vpc_b_cidr
    password             = var.password
    mgmt_gw              = cidrhost(var.fortinet_vpc_mgmt_a_subnet_cidr, 1)
    fgt_priority         = "255"
    fgt-remote-hasync    = element(tolist(aws_network_interface.fgtb-hasync-b-eni.private_ips), 0)
  }
}

### FortiGate B - Userdata - Template Variables

data "template_file" "userdata_fgtb" {
  template = "${file("${path.module}/fgt-userdata.tpl")}"
  vars = {
    fgt_id               = "FGT-B"
    type                 = "${var.fos_license_type}"
    license_file         = "${var.license}"
    fgt_public_ip        = join("/", [element(tolist(aws_network_interface.fgtb-public-b-eni.private_ips), 0), cidrnetmask("${var.fortinet_vpc_public_b_subnet_cidr}")])
    fgt_private_ip       = join("/", [element(tolist(aws_network_interface.fgtb-private-b-eni.private_ips), 0), cidrnetmask("${var.fortinet_vpc_private_b_subnet_cidr}")])
    fgt_hasync_ip        = join("/", [element(tolist(aws_network_interface.fgtb-hasync-b-eni.private_ips), 0), cidrnetmask("${var.fortinet_vpc_hasync_b_subnet_cidr}")])
    fgt_mgmt_ip          = join("/", [element(tolist(aws_network_interface.fgtb-mgmt-b-eni.private_ips), 0), cidrnetmask("${var.fortinet_vpc_mgmt_b_subnet_cidr}")])
    public_gw            = cidrhost(var.fortinet_vpc_public_b_subnet_cidr, 1)
    private_gw           = cidrhost(var.fortinet_vpc_private_b_subnet_cidr, 1)
    spoke1_cidr          = var.spoke_vpc_a_cidr
    spoke2_cidr          = var.spoke_vpc_b_cidr
    password             = var.password
    mgmt_gw              = cidrhost(var.fortinet_vpc_mgmt_b_subnet_cidr, 1)
    fgt_priority         = "100"
    fgt-remote-hasync    = element(tolist(aws_network_interface.fgta-hasync-a-eni.private_ips), 0)
  }
}

### Create the fgta instance

resource "aws_instance" "fgta" {
  ami               = data.aws_ami.fortigate_ami.id
  instance_type     = var.instance_type
  availability_zone = var.availability_zone1
  key_name          = var.keypair
  iam_instance_profile = aws_iam_instance_profile.fortigate_profile.name
  user_data         = "${data.template_file.userdata_fgta.rendered}"
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.fgta-public-a-eni.id
  }
  network_interface {
    device_index         = 1
    network_interface_id = aws_network_interface.fgta-private-a-eni.id
  }
  network_interface {
    device_index         = 2
    network_interface_id = aws_network_interface.fgta-hasync-a-eni.id
  }
  network_interface {
    device_index         = 3
    network_interface_id = aws_network_interface.fgta-mgmt-a-eni.id
  }
  tags = {
    Name = "${var.tag_name_prefix}-fgta"
  }
}

### Create the fgtb instance

resource "aws_instance" "fgtb" {
  ami               = data.aws_ami.fortigate_ami.id
  instance_type     = var.instance_type
  availability_zone = var.availability_zone2
  key_name          = var.keypair
  iam_instance_profile = aws_iam_instance_profile.fortigate_profile.name
  user_data         = "${data.template_file.userdata_fgtb.rendered}" 
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.fgtb-public-b-eni.id
  }
  network_interface {
    device_index         = 1
    network_interface_id = aws_network_interface.fgtb-private-b-eni.id
  }
  network_interface {
    device_index         = 2
    network_interface_id = aws_network_interface.fgtb-hasync-b-eni.id
  }
  network_interface {
    device_index         = 3
    network_interface_id = aws_network_interface.fgtb-mgmt-b-eni.id
  }
  tags = {
    Name = "${var.tag_name_prefix}-fgtb"
  }
}
