resource "aws_default_security_group" "this" {
  vpc_id = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-default-sg"
    }
  )
}
