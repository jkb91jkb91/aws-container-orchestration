
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment_name
    Cluster     = var.cluster_name
  }
}

#SG FOR BASTION HOST
resource "aws_security_group" "bastion" {
  name        = "${var.vpc_name}-bastion-sg"
  description = "Bastion over SSM (no inbound)"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from Internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # FULL EGRESS to VPCE (443) 
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }

  tags = merge(local.common_tags, {
    Name = "${var.vpc_name}-bation-sg"
  })
}


############################## ECR SG ##################################
resource "aws_security_group" "vpc_endpoints_sg" {
  name        = "vpc-endpoints-sg"
  description = "Security Group for VPC Endpoints"
  vpc_id      = var.vpc_id


  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  // EGRESS - Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpc-endpoints-sg"
  }
}