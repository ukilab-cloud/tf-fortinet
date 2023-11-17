####################################
# Ubuntu Linux hosts for testing ###
####################################

### Retrieve AMI info

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

## Security Groups foro Spoke VPCs

resource "aws_security_group" "NSG-spoke-a-ssh-icmp-https" {
  name        = "NSG-spoke-a-ssh-icmp-https"
  description = "Allow SSH, HTTPS and ICMP traffic"
  vpc_id      = aws_vpc.spoke_vpc_a.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8 # the ICMP type number for 'Echo'
    to_port     = 0 # the ICMP code
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0 # the ICMP type number for 'Echo Reply'
    to_port     = 0 # the ICMP code
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name     = "${var.tag_name_prefix}-spoke-a-ssh-icmp-https"
    scenario = var.scenario
  }
}

resource "aws_security_group" "NSG-spoke-b-ssh-icmp-https" {
  name        = "NSG-spoke-b-ssh-icmp-https"
  description = "Allow SSH, HTTPS and ICMP traffic"
  vpc_id      = aws_vpc.spoke_vpc_b.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1 # all icmp
    to_port     = -1 # all icmp
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name     = "${var.tag_name_prefix}-spoke-b-ssh-icmp-https"
    scenario = var.scenario
  }
}


### Test device in spoke1

resource "aws_instance" "instance-spoke-a" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.spoke_vpc_a_workload_a_subnet.id
  private_ip             = cidrhost(var.spoke_vpc_a_workload_a_subnet_cidr, 10)
  vpc_security_group_ids = [aws_security_group.NSG-spoke-a-ssh-icmp-https.id]
  key_name               = var.keypair

  tags = {
    Name     = "${var.tag_name_prefix}-workload-a-spoke-a"
    scenario = var.scenario
    az       = var.availability_zone1
  }
}

### Test device in spoke2

resource "aws_instance" "instance-spoke-b" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.spoke_vpc_b_workload_b_subnet.id
  private_ip             = cidrhost(var.spoke_vpc_b_workload_b_subnet_cidr, 10)
  vpc_security_group_ids = [aws_security_group.NSG-spoke-b-ssh-icmp-https.id]
  key_name               = var.keypair

  tags = {
    Name     = "${var.tag_name_prefix}-workload-b-spoke-b"
    scenario = var.scenario
    az       = var.availability_zone2
  }
}