
# terraform destroy \
#  -target=module.vpc \
#  -target=module.iam \
#  -target=module.sg \
#  -target=module.lb \
#  -target=module.ecs \
#  -target=module.vpcEndpoints


module "vpc" {
  region                          = var.region
  private_subnet_for_bastion_AZ   = var.private_subnet_for_bastion_AZ
  private1_subnet_AZ              = var.private1_subnet_AZ
  private2_subnet_AZ              = var.private2_subnet_AZ
  private_subnet_for_bastion_cidr = var.private_subnet_for_bastion_cidr
  private1_subnet_cidr            = var.private1_subnet_cidr
  private2_subnet_cidr            = var.private2_subnet_cidr
  vpc_name                        = var.vpc_name
  cluster_name                    = var.cluster_name
  vpc_cidr                        = var.vpc_cidr
  project_name                    = var.project_name
  environment_name                = var.environment_name
  source                          = "./modules/vpc"
}

module "sg" {
  vpc_id   = module.vpc.vpc_id
  project_name                       = var.project_name
  environment_name                   = var.environment_name
  cluster_name                       = var.cluster_name
  vpc_name = var.vpc_name
  source   = "./modules/sg"
}

module "vpc_endpoints" {
  region                             = var.region
  project_name                       = var.project_name
  environment_name                   = var.environment_name
  cluster_name                       = var.cluster_name
  vpc_id                             = module.vpc.vpc_id
  vpc_name                           = var.vpc_name
  aws_security_group_bastion_id      = module.sg.aws_security_group_bastion_id
  private_subnet_for_bastion_host_id = module.vpc.private_subnet_for_bastion_host_id
  source                             = "./modules/vpc_endpoints"
}

module "bastion_host" {
  region                             = var.region
  aws_security_group_bastion_id      = module.sg.aws_security_group_bastion_id
  project_name                       = var.project_name
  environment_name                   = var.environment_name
  cluster_name                       = var.cluster_name
  vpc_id                             = module.vpc.vpc_id
  vpc_name                           = var.vpc_name
  private_subnet_for_bastion_host_id = module.vpc.private_subnet_for_bastion_host_id
  source                             = "./modules/ec2"
}

# IAM
# module "iam" {
#   source = "./modules/iam"
# }

# SG
# module "sg" {
#   source = "./modules/sg"
#   vpc_id = module.vpc.vpc_id
# }

#EKS
# module "eks" {
#   source = "./modules/eks"
#   vpc_id = module.vpc.vpc_id
#   cluster_name  =  var.cluster_name
#   cluster_version = var.cluster_version
#   subnet_ids = var.subnet_ids
#   instance_types = var.instance_types
# }



# # ECR
# module "ecr" {
#   source                 = "./modules/ecr"
#   fargate_extra_role_arn = module.iam.fargate_extra_role_arn
# }







