# locals {
#   ssm_endpoints = [
#     "com.amazonaws.${var.region}.ssm",
#     "com.amazonaws.${var.region}.ec2messages",
#     "com.amazonaws.${var.region}.ssmmessages",
#   ]
#   common_tags = {
#     Project     = var.project_name
#     Environment = var.environment_name
#     Cluster     = var.cluster_name
#   }
# }

# resource "aws_vpc_endpoint" "ssm" {
#   for_each            = toset(local.ssm_endpoints)
#   vpc_id              = var.vpc_id
#   service_name        = each.value
#   vpc_endpoint_type   = "Interface"
#   private_dns_enabled = true
#   subnet_ids          = [var.private_subnet_for_bastion_host_id]
#   security_group_ids  = [aws_security_group.vpce.id]
#   tags = merge(local.common_tags, {
#     Name = "${var.vpc_name}-vpc-endpoints"
#   })
# }

# #SG for VPC Endpoints, allow for 443 from BASTION
# resource "aws_security_group" "vpce" {
#   name   = "${var.vpc_name}-vpce-sg"
#   vpc_id = var.vpc_id

#   ingress {
#     from_port       = 443
#     to_port         = 443
#     protocol        = "tcp"
#     security_groups = [var.aws_security_group_bastion_id]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }





#################################################
# INTERFACE: ecr.api
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.us-east-1.ecr.api"
  vpc_endpoint_type = "Interface"

  subnet_ids          = [var.priv_subnet1_id, var.priv_subnet2_id]
  security_group_ids  = [var.endpoint_sg_id]
  private_dns_enabled = true

  tags = {
    Name = "API"
  }
}


# INTERFACE: ecr.dkr
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.us-east-1.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [var.priv_subnet1_id, var.priv_subnet2_id]
  security_group_ids  = [var.endpoint_sg_id]
  private_dns_enabled = true

  tags = {
    Name = "DKR"
  }

}

# # GATEWAY: s3
resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.s3_route_table_ids

  tags = {
    Name = "S3"
  }
}


