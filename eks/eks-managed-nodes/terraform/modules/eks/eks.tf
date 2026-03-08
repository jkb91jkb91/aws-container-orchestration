############################################
# eks.tf — RAW resources (bez modułów)
# Wymaga zmiennych:
#   var.cluster_name         (np. "mini-eks")
#   var.cluster_version      (np. "1.30")
#   var.subnet_ids           (lista subnetów, np. prywatnych)
#   var.instance_types       (lista, np. ["t3.small"])
############################################

# === IAM: Rola dla control plane (EKS Cluster) ===
resource "aws_iam_role" "eks_cluster_role" {
  name               = "${var.cluster_name}-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role.json
}

data "aws_iam_policy_document" "eks_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

# Polityki wymagane przez EKS control plane
resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSVPCResourceController" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

# === EKS Cluster and so called MASTER ===
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids              = var.subnet_ids     # prefer prywatne
    endpoint_private_access = true # Use Bastion Host to connect to Kube Api Server
    # security_group_ids    = [aws_security_group.eks_cluster.id] # CREATE SG TO USE THIS
  }

  enabled_cluster_log_types = ["api","audit","authenticator"]
}

# Poczekaj aż klaster będzie gotowy, zanim stworzymy node group
data "aws_eks_cluster" "this" {
  name = aws_eks_cluster.this.name
}
data "aws_eks_cluster_auth" "this" {
  name = aws_eks_cluster.this.name
}

# === IAM: Rola dla węzłów (Node Group) ===
resource "aws_iam_role" "eks_node_role" {
  name               = "${var.cluster_name}-node-role"
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role.json
}

data "aws_iam_policy_document" "eks_node_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# WORKER NODES >>> REQUIRED POLICIES
resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}
resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# === Managed Node Group: 1 WORKER NODE ===
resource "aws_eks_node_group" "ng1" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-ng1"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 1
  }

  capacity_type  = "ON_DEMAND"         # lub "SPOT"
  instance_types = var.instance_types   # np. ["t3.small"]

  ami_type = "AL2_x86_64"              # domyślne AMI EKS (Amazon Linux 2)
  disk_size = 20

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSVPCResourceController,
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly
  ]

  tags = { Name = "${var.cluster_name}-ng1" }
}

# === (opcjonalnie) SG klastra — jeśli chcesz mieć własny zamiast automatycznego ===
# resource "aws_security_group" "eks_cluster" {
#   name        = "${var.cluster_name}-cluster-sg"
#   description = "EKS cluster security group"
#   vpc_id      = var.vpc_id
#   egress { from_port = 0 to_port = 0 protocol = "-1" cidr_blocks = ["0.0.0.0/0"] }
# }

# === Outputy użyteczne ===
