# ----------------------------------------#
# File: variables.tf
# ----------------------------------------#

variable "aws_region" {
  description = "Region for the VPC"
  default = "us-west-1"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  default = "10.60.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for the public subnet"
  default = "10.60.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR for the private subnet"
  default = "10.60.2.0/24"
}

variable "ami" {
  description = "Amazon Linux AMI"
  default = "ami-925144f2"
}

variable "key_path" {
  description = "SSH Public Key path"
  default = "/Users/noel.arzadon/.ssh/id_rsa_605.pub"
}
