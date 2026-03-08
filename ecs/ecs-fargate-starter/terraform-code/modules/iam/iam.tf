resource "aws_iam_role" "fargate_ecs_task_execution_role" {
  name = "fargateEcsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Inline policy: ECR + CloudWatch Logs
resource "aws_iam_role_policy" "ecr_and_logs_policy" {
  name = "ecr-and-logs-policy"
  role = aws_iam_role.fargate_ecs_task_execution_role.id

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

# Inline policy: SSM access
resource "aws_iam_role_policy" "ssm_policy" {
  name = "ssm-access-policy"
  role = aws_iam_role.fargate_ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:StartSession",
          "ssm:DescribeSessions",
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_role" "fargate_extra_role" {
  name = "fargateExtraRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# CloudWatch logs policy
resource "aws_iam_role_policy" "cloudwatch_policy" {
  name = "cloudwatch-logs-policy"
  role = aws_iam_role.fargate_extra_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# EFS policy with access point condition
resource "aws_iam_role_policy" "efs_policy" {
  name = "efs-access-policy"
  role = aws_iam_role.fargate_extra_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite"
        ],
        Resource = "arn:aws:elasticfilesystem:us-east-1:311141565994:file-system/fs-084acb0a792d03508",
        Condition = {
          StringEquals = {
            "elasticfilesystem:AccessPointArn" = "arn:aws:elasticfilesystem:us-east-1:311141565994:access-point/fsap-033546c113b148773"
          }
        }
      }
    ]
  })
}

# SSM Session Manager policy
resource "aws_iam_role_policy" "ssm_policy_extra" {
  name = "ssm-access-policy"
  role = aws_iam_role.fargate_extra_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:StartSession",
          "ssm:DescribeSessions",
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ],
        Resource = "*"
      }
    ]
  })
}
