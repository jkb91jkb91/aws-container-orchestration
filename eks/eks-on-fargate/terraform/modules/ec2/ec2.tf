data "aws_ami" "al2023" {
  owners      = ["137112412989"] # Amazon
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
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
  associate_public_ip_address = true
  iam_instance_profile        = var.iam_role #aws_iam_instance_profile.bastion.name
  vpc_security_group_ids      = [var.aws_security_group_bastion_id]
  tags = merge(local.common_tags, {
    Name = "${var.vpc_name}-ec2-bastion-host"
  })

  user_data = <<-EOF
  #!/bin/bash
  set -e
  dnf -y update
  dnf -y install unzip
  curl -sSL -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
  chmod +x /usr/local/bin/kubectl

  mkdir -p /home/ec2-user/.kube
  aws eks update-kubeconfig --region us-east-1 --name fargate --kubeconfig /home/ec2-user/.kube/config
  chown -R ec2-user:ec2-user /home/ec2-user/.kube
  chmod 600 /home/ec2-user/.kube/config

  # CoreDNS fix for some EKS Fargate-only setups
  kubectl patch deployment coredns -n kube-system --type json -p='[{"op": "remove", "path": "/spec/template/spec/tolerations"}]' || true

  kubectl create namespace jobs-namespace --dry-run=client -o yaml | kubectl apply -f -
  kubectl create namespace aws-observability --dry-run=client -o yaml | kubectl apply -f -
  kubectl label namespace aws-observability aws-observability=enabled --overwrite

EOF



# apiVersion: v1
# kind: ConfigMap
# metadata:
#   name: aws-logging
#   namespace: aws-observability
# data:
#   filters.conf: |
#     [FILTER]
#         Name                kubernetes
#         Match               kube.*
#         Merge_Log           On
#         Keep_Log            Off
#         K8S-Logging.Parser  On
#         K8S-Logging.Exclude Off

#   output.conf: |
#     [OUTPUT]
#         Name                cloudwatch_logs
#         Match               kube.*
#         region              us-east-1
#         log_group_name      /Eks-Jobs
#         log_stream_prefix   jobs-
#         auto_create_group   true

#   parsers.conf: |
#     [PARSER]
#         Name   json
#         Format json

# kubectl apply -f aws-logging.yaml

##########################################################################################

apiVersion: batch/v1
kind: Job
metadata:
  name: hello-job
  namespace: default
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: hello
          image: busybox:1.36
          command: ["sh", "-c", "echo 'Hello from Job'; sleep 5; echo 'Done'"]
  backoffLimit: 1

###########################################################################################3
  # Enforce IMDSv2 as good practice
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



