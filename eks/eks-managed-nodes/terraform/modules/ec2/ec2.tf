# Amazon Linux 2023 (x86_64) - KONKRETNA WERSJA
data "aws_ami" "al2023" {
  owners      = ["137112412989"] # Amazon
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.9.20250929.0-kernel-6.1-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}


locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment_name
    Cluster     = var.cluster_name
  }
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = "t3.micro"
  subnet_id                   = var.private_subnet_for_bastion_host_id
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.bastion.name
  vpc_security_group_ids      = [var.aws_security_group_bastion_id]
  tags = merge(local.common_tags, {
    Name = "${var.vpc_name}-ec2-bastion-host"
  })

  # Bez SSH – opcjonalny zestaw narzędzi
  # user_data = <<-EOF
  #   #!/bin/bash
  #   set -e
  #   dnf -y update
  #   dnf -y install unzip
  #   # kubectl (ostatnia stabilna)
  #   curl -sSL -o /usr/local/bin/kubectl \
  #     https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
  #   chmod +x /usr/local/bin/kubectl
  # EOF

  # Wymuś IMDSv2 (dobry nawyk)
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_size = 16
    volume_type = "gp3"
    encrypted   = false
  }
}

resource "aws_iam_role" "bastion" {
  name               = "${var.vpc_name}-bastion-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
  tags = merge(local.common_tags, {
    Name = "${var.vpc_name}-ec2-bastion-role"
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${var.vpc_name}-bastion-profile"
  role = aws_iam_role.bastion.name
}