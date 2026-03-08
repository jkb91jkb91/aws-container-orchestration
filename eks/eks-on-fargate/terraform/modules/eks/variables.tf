
variable "vpc_name" { type = string }
variable "cluster_name" { type = string }
#variable "cluster_version" { type = string }
variable "vpc_id" { type = string }
variable "aws_security_group_bastion_id" { type = string }
variable "subnet_ids" {
  description = "List of subnet IDs for EKS (prefer private subnets)"
  type        = list(string)
}

variable "iam_role_bastion_arn" {
  type = string
}

