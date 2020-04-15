resource "aws_ecs_cluster" "this" {
  name = var.name

  dynamic "setting" {

    for_each = var.settings

    content {
      name  = setting.key
      value = setting.value
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}