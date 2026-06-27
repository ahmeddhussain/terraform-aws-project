resource "aws_vpc" "my-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "my-vpc-${var.vpc_cidr}"
    Environment = var.environment
  }
}

data "aws_availability_zones" "available" {}
