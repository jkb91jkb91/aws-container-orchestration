output "vpc_id" {
  value = aws_vpc.eks_vpc.id
}

output "private_subnet_for_bastion_host_id" {
  value = aws_subnet.private_subnet_for_bastion_host.id
}