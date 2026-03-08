variable "region" { type = string }

variable "vpc_name" { type = string }
# TAGS
variable "cluster_name" { type = string }
variable "project_name" { type = string }
variable "environment_name" { type = string }

# REQUIRED OUTPUTS FROM MODULE VPC
variable "vpc_id" { type = string }
variable "private_subnet_for_bastion_host_id" { type = string }
variable "aws_security_group_bastion_id" { type = string }