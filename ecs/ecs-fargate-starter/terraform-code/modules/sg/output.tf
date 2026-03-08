output "endpoint_sg_id" {
  description = "endpoint_sg_id"
  value       = aws_security_group.vpc_endpoints_sg.id
}

output "task_sg_id" {
  description = "task_sg_id"
  value       = aws_security_group.fargate_service_sg.id
}


output "sg1_id" {
  description = "sg1_id"
  value       = aws_security_group.fargate_service_sg.id
}




