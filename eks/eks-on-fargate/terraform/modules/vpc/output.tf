output "vpc_id" {
  value = aws_vpc.eks_vpc.id
}

output "private_subnet_for_bastion_host_id" {
  value = aws_subnet.private_subnet_for_bastion_host.id
}

output "public_subnet_for_bastion_host_id" {
  value = aws_subnet.public_subnet.id
}

output "private_subnet1_id" {
  value = aws_subnet.private_subnet_1.id
}

output "private_subnet2_id" {
  value = aws_subnet.private_subnet_2.id
}

output "s3_route_table_ids" {
  description = "s3_route_table_ids"
  value       = [aws_route_table.private_route_table.id]
}