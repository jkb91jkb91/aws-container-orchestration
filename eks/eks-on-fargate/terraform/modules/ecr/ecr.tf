resource "aws_ecr_repository" "eks_repo" {
  name                 = "eks_repo"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name = "JUST_NAME"
    App  = "JUST_APP"
  }
}

