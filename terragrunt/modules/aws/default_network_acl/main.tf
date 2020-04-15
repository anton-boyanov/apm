resource "aws_default_network_acl" "this" {
  default_network_acl_id = var.default_network_acl_id

  dynamic "ingress" {

    for_each = var.ingress

    content {
      rule_no    = lookup(ingress.value, "rule_no", null)
      action     = lookup(ingress.value, "action", null)
      from_port  = lookup(ingress.value, "from_port", null)
      to_port    = lookup(ingress.value, "to_port", null)
      protocol   = lookup(ingress.value, "protocol", null)
      cidr_block = lookup(ingress.value, "cidr_block", null)
    }
  }

  dynamic "egress" {

    for_each = var.egress

    content {
      rule_no    = lookup(egress.value, "rule_no", null)
      action     = lookup(egress.value, "action", null)
      from_port  = lookup(egress.value, "from_port", null)
      to_port    = lookup(egress.value, "to_port", null)
      protocol   = lookup(egress.value, "protocol", null)
      cidr_block = lookup(egress.value, "cidr_block", null)
    }
  }


  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-default-nacl"
    }
  )
}
