# OUTPUT ONLY FOR DEBUGGING PURPOSES VPC
output "available_zones" {
  value = data.aws_availability_zones.available.names
}

output "vpc_id" {
  value = data.aws_vpcs.vpc.ids[0]
}

output "subnet_id" {
  value = data.aws_subnets.efs_subnet.ids[0]
}

# output "ecr_repo_url" {
#   value = module.ecr.ecr_repo_url
# }
