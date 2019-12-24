resource "aws_ecr_repository" "ecr_repository" {
  name = var.name
}

resource "aws_ecr_lifecycle_policy" "ecr_lifecycle_policy" {
  depends_on = [aws_ecr_repository.ecr_repository]

  count      = var.lifecyle_policy != "" ? 1 : 0
  repository = var.name
  policy     = var.lifecyle_policy
}

