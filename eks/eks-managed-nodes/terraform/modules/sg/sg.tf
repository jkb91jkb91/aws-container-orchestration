
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

  # NO INGRESS

  # FULL EGRESS to VPCE (443) 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }

  tags = merge(local.common_tags, {
    Name = "${var.vpc_name}-bation-sg"
  })
}