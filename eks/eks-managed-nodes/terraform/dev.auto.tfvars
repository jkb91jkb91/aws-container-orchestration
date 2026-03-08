region                          = "us-east-1"
vpc_name                        = "vpc-eks"
vpc_cidr                        = "10.0.0.0/16"
private_subnet_for_bastion_cidr = "10.0.1.0/24"
private1_subnet_cidr            = "10.0.2.0/24"
private2_subnet_cidr            = "10.0.3.0/24"

private_subnet_for_bastion_AZ = "us-east-1a"
private1_subnet_AZ            = "us-east-1b"
private2_subnet_AZ            = "us-east-1c"


############################################
cluster_name     = "eks-platform-cluster"
project_name     = "platform_eks"
environment_name = "dev"
cluster_version  = ""
