resource "aws_route53_zone" "this" {
  name = var.zone_name

  dynamic "vpc" {
    for_each = var.vpc_id == null ? [] : [1]
    content {
      vpc_id = var.vpc_id
    }
  }

  force_destroy = true

  tags = merge(
    var.tags,
    {
      zone_type = var.vpc_id == null ? "public" : "private"
    }
  )

  comment = var.comment
}