resource "aws_rds_cluster_parameter_group" "this" {
  name        = var.name
  description = var.tags.Description
  family      = var.cluster_family

  dynamic "parameter" {
    for_each = var.cluster_parameters
    content {
      apply_method = lookup(parameter.value, "apply_method", "pending-reboot")
      name         = parameter.value.name
      value        = parameter.value.value
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}