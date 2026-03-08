# OUTPUT ONLY FOR DEBUGGING PURPOSES VPC
output "available_zones" {
  value = data.aws_availability_zones.available.names
}

output "vpc_id" {
  value = data.aws_vpcs.vpc.ids[0]
}