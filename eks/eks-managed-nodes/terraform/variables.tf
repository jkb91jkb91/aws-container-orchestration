variable "region" { type = string }

variable "vpc_name" { type = string }
variable "vpc_cidr" { type = string }
variable "private_subnet_for_bastion_cidr" { type = string }
variable "private1_subnet_cidr" { type = string }
variable "private2_subnet_cidr" { type = string }

variable "private_subnet_for_bastion_AZ" { type = string }
variable "private1_subnet_AZ" { type = string }
variable "private2_subnet_AZ" { type = string }


variable "cluster_name" { type = string }
variable "project_name" { type = string }
variable "environment_name" { type = string }


############################# EKS ##########################
# variable "cluster_name" { type = string }
# variable "cluster_version" { type = string }
# variable "subnet_ids" { type = list(string) }
# variable "instance_types" { type = list(string) }