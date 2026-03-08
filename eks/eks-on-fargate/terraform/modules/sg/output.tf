
output "aws_security_group_bastion_id" {
  value = aws_security_group.bastion.id
}

output "endpoint_sg_id" {
  description = "endpoint_sg_id"
  value       = aws_security_group.vpc_endpoints_sg.id
}
