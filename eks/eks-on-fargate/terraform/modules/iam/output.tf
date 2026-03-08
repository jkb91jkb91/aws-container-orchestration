output "iam_role_bastion_arn" {
  value = aws_iam_role.bastion.arn
}

output "iam_role_ec2_name" {
  value = aws_iam_instance_profile.bastion.name
}
