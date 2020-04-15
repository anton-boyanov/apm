resource "aws_elasticache_subnet_group" "this" {
  name       = var.name
  subnet_ids = var.subnet_ids

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}