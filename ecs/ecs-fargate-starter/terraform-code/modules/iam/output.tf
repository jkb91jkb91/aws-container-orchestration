output "fargate_extra_role_arn" {
  description = "ARN of the Fargate extra IAM role"
  value       = aws_iam_role.fargate_extra_role.arn
}

output "execution_role_arn" {
  value = aws_iam_role.fargate_ecs_task_execution_role.arn
}

output "task_role_arn" {
  value = aws_iam_role.fargate_extra_role.arn
}