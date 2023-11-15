##############################################################################################################
#
# AWS Transit Gateway
# FortiGate setup with Active/Passive in Multiple Availability Zones
#
##############################################################################################################

##############################################################################################################
# GENERAL
##############################################################################################################

# Security Groups


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
    Name     = "NSG-vpc-fortinet-ssh-icmp-https"
    scenario = var.scenario
  }
}

##############################################################################################################
# FORTIGATES VM
##############################################################################################################
# Create the IAM role/profile for the API Call
resource "aws_iam_instance_profile" "APICall_profile" {
  name = "APICall_profile"
  role = aws_iam_role.APICallrole.name
}

resource "aws_iam_role" "APICallrole" {
  name = "APICall_role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
              "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }https://signin.aws.amazon.com/saml
    ]
}
EOF
}

resource "aws_iam_policy" "APICallpolicy" {
  name        = "APICall_policy"
  path        = "/"
  description = "Policies for the FGT APICall Role"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Action": 
            [
              "ec2:Describe*",
              "ec2:AssociateAddress",
              "ec2:AssignPrivateIpAddresses",
              "ec2:UnassignPrivateIpAddresses",
              "ec2:ReplaceRoute"
            ],
            "Resource": "*"
        }
      ]
}
EOF
}

resource "aws_iam_policy_attachment" "APICall-attach" {
  name       = "APICall-attachment"
  roles      = [aws_iam_role.APICallrole.name]
  policy_arn = aws_iam_policy.APICallpolicy.arn
}


# Create all the eni interfaces
resource "aws_network_interface" "fgta-public-a-eni" {
  subnet_id         = aws_subnet.public_a_subnet.id
  security_groups   = [aws_security_group.NSG-vpc-fortinet-ssh-icmp-https.id]
  source_dest_check = false
  tags = {
    Name = "${var.tag_name_prefix}-fgta-public-eni"
  }
}

resource "aws_network_interface" "fgtb-public-b-eni" {
  subnet_id         = aws_subnet.public_b_subnet.id
  security_groups   = [aws_security_group.NSG-vpc-fortinet-ssh-icmp-https.id]
  source_dest_check = false
  tags = {
    Name = "${var.tag_name_prefix}-fgtb-public-eni"
  }
}

resource "aws_network_interface" "fgta-private-a-eni" {
  subnet_id         = aws_subnet.private_a_subnet.id
  security_groups   = [aws_security_group.NSG-vpc-fortinet-ssh-icmp-https.id]
  source_dest_check = false
  tags = {
    Name = "${var.tag_name_prefix}-fgta-private-eni"
  }
}

resource "aws_network_interface" "fgtb-private-b-eni" {
  subnet_id         = aws_subnet.private_b_subnet.id
  security_groups   = [aws_security_group.NSG-vpc-fortinet-ssh-icmp-https.id]
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
  source_dest_check = false
  tags = {
    Name = "${var.tag_name_prefix}-fgta-mgmt-eni"
  }
}

resource "aws_network_interface" "fgtb-mgmt-b-eni" {
  subnet_id         = aws_subnet.mgmt_b_subnet.id
  security_groups   = [aws_security_group.NSG-vpc-fortinet-ssh-icmp-https.id]
  source_dest_check = false
  tags = {
    Name = "${var.tag_name_prefix}-fgtb-mgmt-eni"
  }
}

# Create and attach the eip to the units
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

resource "aws_eip" "eip-shared" {
  depends_on        = [aws_instance.fgta]
  domain            = "vpc"
  network_interface = aws_network_interface.fgta-public-a-eni.id
  tags = {
    Name = "${var.tag_name_prefix}-fgt-cluster-eip"
  }
}

# Create the instances
resource "aws_instance" "fgta" {
    //it will use region, architect, and license type to decide which ami to use for deployment
  ami               = var.fgtami[var.region][var.arch][var.license_type]
  instance_type     = var.instance_type
  availability_zone = var.availability_zone1
  key_name          = var.keypair
  user_data = templatefile("./fgt-userdata.tpl", {
    fgt_id               = "FGT-A"
    type                 = "${var.license_type}"
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
  })
  iam_instance_profile = aws_iam_instance_profile.APICall_profile.name
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
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-fgta"
  }
}

resource "aws_instance" "fgtb" {
    //it will use region, architect, and license type to decide which ami to use for deployment
  ami               = var.fgtami[var.region][var.arch][var.license_type]
  instance_type     = var.instance_type
  availability_zone = var.availability_zone2
  key_name          = var.keypair
  user_data = templatefile("./fgt-userdata.tpl", {
    fgt_id               = "FGT-B"
    type                 = "${var.license_type}"
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
  })
  iam_instance_profile = aws_iam_instance_profile.APICall_profile.name
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
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-fgtb"
  }
}
