resource "aws_eip" "this" {
  vpc = true

  tags = merge(
    var.tags,
    {
      Name = var.name_prefix == null ? "${var.vpc_name}-eip" : "${var.vpc_name}-${var.name_prefix}-eip"
    }
  )
}
