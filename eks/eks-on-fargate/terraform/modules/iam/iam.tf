data "aws_caller_identity" "current" {}

resource "aws_iam_role_policy" "eks_describe_cluster" {
  name = "${var.vpc_name}-eks-describe-cluster"
  role = aws_iam_role.bastion.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowDescribeEKSCluster",
        Effect = "Allow",
        Action = [
          "eks:DescribeCluster"
        ],
        Resource = [
          "arn:aws:eks:${var.region}:${data.aws_caller_identity.current.account_id}:cluster/${var.cluster_name}"
        ]
      }
    ]
  })
}


resource "aws_iam_role" "bastion" {
  name = "${var.vpc_name}-bastion-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
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


############################ ECR POLICIES ##############################
# Inline policy: ECR + CloudWatch Logs
resource "aws_iam_role_policy" "ecr_and_logs_policy" {
  name = "ecr-and-logs-policy"
  role = aws_iam_role.bastion.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}