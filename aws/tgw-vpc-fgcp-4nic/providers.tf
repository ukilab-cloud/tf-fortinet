#################################
### Terraform Provider Config ###
##################################

terraform {
  required_version = ">= 1.6"
}

##############################################################################################################
# Deployment in AWS
##############################################################################################################
provider "aws" {
# comment if using IAM Role
  access_key = var.access_key
  secret_key = var.secret_key
#  region     = var.region
  # Uncomment if using AWS SSO:
  # token      = var.token
}
