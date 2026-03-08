
module "vpc" {
  source = "./modules/vpc"
}

module "iam" {
  source = "./modules/iam"
}

module "sg" {
  source = "./modules/sg"
  vpc_id = module.vpc.vpc_id
}

module "lb" {
  source          = "./modules/lb"
  certificate_arn = var.certificate_arn
  vpc_id          = module.vpc.vpc_id
  subnet1_id      = module.vpc.public1_subnet_id
  subnet2_id      = module.vpc.public2_subnet_id
  apps            = var.apps
}

# module "route53" {
#   source          = "./modules/route53"
#   loadb_name      = module.lb.alb_dns_name
#   hosted_zone_name = var.hosted_zone_name
# }


module "ecs" {
  source                 = "./modules/ecs"
  cluster_name           = var.cluster_name
  execution_role_arn     = module.iam.execution_role_arn
  task_role_arn          = module.iam.task_role_arn
  subnet1_id             = module.vpc.subnet1_id
  subnet2_id             = module.vpc.subnet2_id
  sg1_id                 = module.sg.sg1_id
  target_group_arns      = module.lb.target_group_arns
  log_group_name         = var.log_group_name
  region                 = var.region
  logs_retention_in_days = var.logs_retention_in_days
  apps                   = var.apps

  depends_on = [module.sg, module.vpc, module.lb]
}









