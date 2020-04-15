resource "aws_security_group" "this" {
  name        = var.name_prefix == null ? "${var.vpc_name}-sg" : "${var.vpc_name}-${var.name_prefix}-sg"
  description = var.tags.Description
  vpc_id      = var.vpc_id


  dynamic "ingress" {

    for_each = var.ingress

    content {
      description = lookup(ingress.value, "description", null)
      from_port   = lookup(ingress.value, "from_port", null)
      to_port     = lookup(ingress.value, "to_port", null)
      protocol    = lookup(ingress.value, "protocol", null)
      cidr_blocks = lookup(ingress.value, "cidr_blocks", null)
    }
  }

  dynamic "egress" {

    for_each = var.egress

    content {
      description = lookup(egress.value, "description", null)
      from_port   = lookup(egress.value, "from_port", null)
      to_port     = lookup(egress.value, "to_port", null)
      protocol    = lookup(egress.value, "protocol", null)
      cidr_blocks = lookup(egress.value, "cidr_blocks", null)
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.name_prefix == null ? "${var.vpc_name}-sg" : "${var.vpc_name}-${var.name_prefix}-sg"
    }
  )
}