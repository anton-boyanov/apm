locals {
  lifecyle_policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 100,
            "description": "ECR image retention policy",
            "selection": {
                "tagStatus": "untagged",
                "countType": "imageCountMoreThan",
                "countNumber": 1
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "aws_ecr_repository" "this" {
  count = length(var.names)
  name  = "${var.application_name}-${var.environment}-${var.names[count.index]}"
}

resource "aws_ecr_lifecycle_policy" "this" {
  depends_on = [aws_ecr_repository.this]

//  count      = local.lifecyle_policy != "" ? 1 : 0
  repository = aws_ecr_repository.this.name
  policy     = local.lifecyle_policy
}
