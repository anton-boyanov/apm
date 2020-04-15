resource "aws_default_route_table" "this" {
  default_route_table_id = var.default_route_table_id
  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-main-rtb"
    }
  )
}
