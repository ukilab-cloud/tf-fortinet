##############################################################################################################
#
# FortiGate Terraform deployment
# Active Passive High Availability MultiAZ with AWS Transit Gateway with VPC standard attachment -
#
##############################################################################################################

# Access and secret keys to your environment
variable "access_key" {}
variable "secret_key" {}

# Uncomment if using AWS SSO:
# variable "token"      {}
# References of your environment

variable "region" {
  description = "Provide the region to deploy the VPC in"
  default     = "eu-west-2"
}

variable "availability_zone1" {
  description = "Provide the first availability zone to create the subnets in"
  default     = "eu-west-2a"
}

variable "availability_zone2" {
  description = "Provide the second availability zone to create the subnets in"
  default     = "eu-west-2b"
}

#Key Pair Name

variable "keypair" {
  description = "Provide a keypair for accessing the FortiGate instances"
  default     = "aplab"
}


# Prefix for all resources created for this deployment in AWS
variable "tag_name_prefix" {
  description = "Provide a common tag prefix value that will be used in the name tag for all resources"
  default     = "aplab"
}

## Remove the use of this variable
variable "tag_name_unique" {
  description = "Provide a unique tag prefix value that will be used in the name tag for each modules resources"
  default     = "terraform"
}

// license file for the active fgt
variable "license" {
  // Change to your own byol license file, license.lic
  type    = string
  default = "license.txt"
}

// license file for the passive fgt
variable "license2" {
  // Change to your own byol license file, license2.lic
  type    = string
  default = "license2.txt"
}

// License Type to create FortiGate-VM
// Provide the license type for FortiGate-VM Instances, either byol or payg.
variable "license_type" {
  default = "payg"
}

// instance architect
// Either arm or x86
variable "arch" {
  default = "x86"
}

// instance type needs to match the architect
// c5n.xlarge is x86_64
// c6g.xlarge is arm
// For detail, refer to https://aws.amazon.com/ec2/instance-types/
variable "instance_type" {
  description = "Provide the instance type for the FortiGate instances"
  default = "c5n.xlarge"
}

#############################################################################################################
#  AMI

// AMIs for FGTVM-7.4.0
variable "fgtami" {
  type = map(any)
  default = {
    us-east-1 = {
      arm = {
        payg = "ami-06e3c91359990ffe7"
        byol = "ami-021b56da1d6c1aeec"
      },
      x86 = {
        payg = "ami-059d36a8887155edb"
        byol = "ami-0b8f59ecef2c7b3c7"
      }
    },
    us-east-2 = {
      arm = {
        payg = "ami-08da0f3f241a08578"
        byol = "ami-0d5ea61acd6bf9476"
      },
      x86 = {
        payg = "ami-06bc98ab2e7292d62"
        byol = "ami-010ad23a69290d22a"
      }
    },
    us-west-1 = {
      arm = {
        payg = "ami-0661f905965b2ca5c"
        byol = "ami-03026d4235ca1e41a"
      },
      x86 = {
        payg = "ami-033d3e55ad5786e8c"
        byol = "ami-0e0094632333747a6"
      }
    },
    us-west-2 = {
      arm = {
        payg = "ami-0157bfb8acffa1e52"
        byol = "ami-0b67089acc9803c34"
      },
      x86 = {
        payg = "ami-0e9df54e982f0b95d"
        byol = "ami-03dc44741f19fd88e"
      }
    },
    af-south-1 = {
      arm = {
        payg = "ami-044e4193e5cb4ed70"
        byol = "ami-0b10880ac9c0555dd"
      },
      x86 = {
        payg = "ami-00bcb8cd55791dfc5"
        byol = "ami-0f4e7b8f1aea63878"
      }
    },
    ap-east-1 = {
      arm = {
        payg = "ami-02e2f06d1eab65399"
        byol = "ami-08907cc7df7db463c"
      },
      x86 = {
        payg = "ami-0bae5f6ab54664346"
        byol = "ami-08e7e30ecee87be1c"
      }
    },
    ap-southeast-3 = {
      arm = {
        payg = "ami-006f1bc99dbe0698f"
        byol = "ami-073ef556a7a10d643"
      },
      x86 = {
        payg = "ami-0a7257dfd23ba55f5"
        byol = "ami-0633e3f18ac7ae987"
      }
    },
    ap-south-1 = {
      arm = {
        payg = "ami-0399c1c042bfb2854"
        byol = "ami-05abd2db8a87bdb96"
      },
      x86 = {
        payg = "ami-02f3189a4ec9e039e"
        byol = "ami-0db6f58e41efd0676"
      }
    },
    ap-northeast-3 = {
      arm = {
        payg = "ami-050b1765c5b4d514c"
        byol = "ami-02d8c15340e4a9aec"
      },
      x86 = {
        payg = "ami-033f084fdc040d3ae"
        byol = "ami-085b34927e5b0d0c6"
      }
    },
    ap-northeast-2 = {
      arm = {
        payg = "ami-0434af6cabfebd5fe"
        byol = "ami-05bc309c2506b1835"
      },
      x86 = {
        payg = "ami-0de094fd2bb682123"
        byol = "ami-0316c604deee5a7a5"
      }
    },
    ap-southeast-1 = {
      arm = {
        payg = "ami-0433f9a734dfb3de4"
        byol = "ami-048426aa09b9b68a4"
      },
      x86 = {
        payg = "ami-017d7dadcac8a5c9f"
        byol = "ami-0404384f7eb043430"
      }
    },
    ap-southeast-2 = {
      arm = {
        payg = "ami-0429f2bf5343882ec"
        byol = "ami-019ecd4ccd2781385"
      },
      x86 = {
        payg = "ami-09692eb6064201eec"
        byol = "ami-070ebf1937d82dabb"
      }
    },
    ap-northeast-1 = {
      arm = {
        payg = "ami-07f087774e86fec56"
        byol = "ami-0a78aca6670615572"
      },
      x86 = {
        payg = "ami-04add78aafe386147"
        byol = "ami-02ec01d79dc0539aa"
      }
    },
    ca-central-1 = {
      arm = {
        payg = "ami-09565d6692820e71f"
        byol = "ami-0680f32ad167fe326"
      },
      x86 = {
        payg = "ami-08aa1f3d6b6c43747"
        byol = "ami-0972a5dadb4c5fb1c"
      }
    },
    eu-central-1 = {
      arm = {
        payg = "ami-050377efa504afc99"
        byol = "ami-0d8b5c3ceb8712640"
      },
      x86 = {
        payg = "ami-031e9298bdda5f59c"
        byol = "ami-0475f5b8ebc18cc54"
      }
    },
    eu-west-1 = {
      arm = {
        payg = "ami-032bc2ec2bce29f9b"
        byol = "ami-0f7d6d35ad2b76568"
      },
      x86 = {
        payg = "ami-0c323826438c86a3b"
        byol = "ami-081cf57cdce2c31b6"
      }
    },
    eu-west-2 = {
      arm = {
        payg = "ami-02e72345a5fc48438"
        byol = "ami-0bbb1793298b8e32a"
      },
      x86 = {
        payg = "ami-0f5b16ee38c416d3e"
        byol = "ami-0030106809410fb04"
      }
    },
    eu-south-1 = {
      arm = {
        payg = "ami-087abdeefe46659af"
        byol = "ami-0e74fbbd997fa49c1"
      },
      x86 = {
        payg = "ami-0af1c9f9828e0ac50"
        byol = "ami-05fd0b2ae18beaeb9"
      }
    },
    eu-west-3 = {
      arm = {
        payg = "ami-0b8c3ad56ebc15eaa"
        byol = "ami-0b12844236013fd01"
      },
      x86 = {
        payg = "ami-02ea27a269dbf0d88"
        byol = "ami-0756cb6100f26c7e8"
      }
    },
    eu-north-1 = {
      arm = {
        payg = "ami-015e8f0c23d38327f"
        byol = "ami-053e35644c7f233d9"
      },
      x86 = {
        payg = "ami-02769e9ccad124389"
        byol = "ami-08395b4eafe53a06a"
      }
    },
     me-south-1 = {
      arm = {
        payg = "ami-0863759c8b872a2d2"
        byol = "ami-048b46d03fadb2b17"
      },
      x86 = {
        payg = "ami-028b61ba0586b59ff"
        byol = "ami-022969d6e39067bd8"
      }
    },
    sa-east-1 = {
      arm = {
        payg = "ami-063d7c9b21af7969a"
        byol = "ami-0926da1f5b01f18fa"
      },
      x86 = {
        payg = "ami-0df6461e983f0f521"
        byol = "ami-0363b7f2f7c436e61"
      }
    }
  }
}

variable "scenario" {
  default = "ap-tgw"
}

// password for FortiGate HA configuration
variable "password" {
  default = "fortinet"
}

# References to your Networks
# fortinet VPC
variable "fortinet_vpc_cidr" {
  description = "Provide the network CIDR for the VPC"
  default     = "10.99.99.0/24"
}

#### public subnets
variable "fortinet_vpc_public_a_subnet_cidr" {
  description = "Provide the network CIDR for Public A in fortinet vpc"
  default     = "10.99.99.80/28"
}

variable "fortinet_vpc_public_a_gw" {
  description = "Provide the default local router IP for the Public B subnet"
  default     = "10.99.99.81/28"
}

variable "fortinet_vpc_public_b_subnet_cidr" {
  description = "Provide the network CIDR for the Public B subnet in fortinet vpc"
  default     = "10.99.99.0/28"
}

variable "fortinet_vpc_public_b_gw" {
  description = "Provide the default local router IP for the Public B subnet"
  default     = "10.99.99.1/28"
}

#### private subnets
variable "fortinet_vpc_private_a_subnet_cidr" {
  description = "Provide the network CIDR for private A in fortinet vpc"
  default     = "10.99.99.96/28"
}

variable "fortinet_vpc_private_a_gw" {
  description = "Provide the default local router IP for the Private B subnet"
  default     = "10.99.99.97/28"
}

variable "fortinet_vpc_private_b_subnet_cidr" {
  description = "Provide the network CIDR for the Private B subnet in fortinet vpc"
  default     = "10.99.99.16/28"
}

variable "fortinet_vpc_private_b_gw" {
  description = "Provide the default local router IP for the Private B subnet"
  default     = "10.99.99.17/28"
}

#### transit subnets
variable "fortinet_vpc_transit_a_subnet_cidr" {
  description = "Provide the network CIDR for the Transit A subnet in fortinet vpc"
  default     = "10.99.99.144/28"
}

variable "fortinet_vpc_transit_b_subnet_cidr" {
  description = "Provide the network CIDR for the Transit B subnet in fortinet vpc"
  default     = "10.99.99.64/28"
}

#### mgmt subnets
variable "fortinet_vpc_mgmt_a_subnet_cidr" {
  description = "Provide the network CIDR for the Mgmt A subnet in fortinet vpc"
  default     = "10.99.99.112/28"
}

variable "fortinet_vpc_mgmt_a_gw" {
  description = "Provide the default local router IP for the Mgmt A subnet"
  default     = "10.99.99.113/28"
}

variable "fortinet_vpc_mgmt_b_subnet_cidr" {
  description = "Provide the network CIDR for the Mgmt B subnet in fortinet vpc"
  default     = "10.99.99.32/28"
}

variable "fortinet_vpc_mgmt_b_gw" {
  description = "Provide the default local router IP for the Mgmt B subnet"
  default     = "10.99.99.33/28"
}

#### Hasync subnets
variable "fortinet_vpc_hasync_a_subnet_cidr" {
  description = "Provide the network CIDR for the HASync A subnet in fortinet vpc"
  default     = "10.99.99.128/28"
}

variable "fortinet_vpc_hasync_b_subnet_cidr" {
  description = "Provide the network CIDR for the HASync B subnet in fortinet vpc"
  default     = "10.99.99.48/28"
}

# spoke-a VPC
variable "spoke_vpc_a_cidr" {
  description = "Provide the network CIDR for the Spoke A VPC"
  default     = "10.99.98.0/24"
}

variable "spoke_vpc_a_workload_a_subnet_cidr" {
  description = "Provide the network CIDR for the Workload A subnet in spoke vpc a"
  default     = "10.99.98.0/26"
}

variable "spoke_vpc_a_transit_a_subnet_cidr" {
  description = "Provide the network CIDR for the Transit A subnet in spoke vpc a"
  default     = "10.99.98.64/26"
}

# spoke2 VPC
variable "spoke_vpc_b_cidr" {
  description = "Provide the network CIDR for the Spoke B VPC"
  default     = "10.99.97.0/24"
}

variable "spoke_vpc_b_workload_b_subnet_cidr" {
  description = "Provide the network CIDR for the Workload B subnet in spoke vpc b"
  default     = "10.99.97.0/26"
}

variable "spoke_vpc_b_transit_b_subnet_cidr" {
  description = "Provide the network CIDR for the Transit B subnet in spoke vpc b"
  default     = "10.99.97.64/26"
}


# References to your FortiGate
variable "ami" {
  description = "Provide an AMI for the FortiGate instances"
  default     = "automatically gathered by terraform modules"
}

variable "cidr_for_access" {
  description = "Provide a network CIDR for accessing the FortiGate instances"
  default     = "0.0.0.0/0"
}
