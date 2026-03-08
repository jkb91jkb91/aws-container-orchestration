# DATA REQUIRED FOR MANY MODULES

data "aws_availability_zones" "available" {
}

data "aws_vpcs" "vpc" {
}

data "aws_subnets" "efs_subnet" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpcs.vpc.ids[0]]
  }
}

