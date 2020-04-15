resource "aws_route_table" "this" {
  vpc_id = var.vpc_id

  dynamic "route" {

    for_each = var.routes

    content {
      cidr_block = lookup(route.value, "cidr_block", null)

      gateway_id                = lookup(route.value, "gateway_id", null)
      egress_only_gateway_id    = lookup(route.value, "egress_only_gateway_id", null)
      instance_id               = lookup(route.value, "instance_id", null)
      nat_gateway_id            = lookup(route.value, "nat_gateway_id", null)
      network_interface_id      = lookup(route.value, "network_interface_id", null)
      transit_gateway_id        = lookup(route.value, "transit_gateway_id", null)
      vpc_peering_connection_id = lookup(route.value, "vpc_peering_connection_id", null)
    }

  }

  tags = merge(
    var.tags,
    {
      Name = var.name_prefix == null ? "${var.vpc_name}-rtb" : "${var.vpc_name}-${var.name_prefix}-rtb"
    }
  )

}

resource "aws_route_table_association" "this" {
  count          = length(var.subnet_association_ids) > 0 ? length(var.subnet_association_ids) : 0
  subnet_id      = var.subnet_association_ids[count.index]
  route_table_id = aws_route_table.this.id
}
