locals {
  rds_max_connections_per_type = {
    "db.t2.micro"   = 66
    "db.t2.small"   = 150
    "db.t2.medium"  = 312
    "db.t2.large"   = 648
    "db.t3.large"   = 648
    "db.m4.large"   = 648
    "db.m5.large"   = 648
    "db.m5.xlarge"  = 2000
    "db.m5.2xlarge" = 3000
    "db.r4.large"   = 648
    "db.r5.large"   = 1600
  }
}

resource "aws_db_parameter_group" "this" {
  name        = var.name
  description = var.tags.Description
  family      = var.cluster_family

  dynamic "parameter" {
    for_each = var.instance_parameters
    content {
      apply_method = lookup(parameter.value, "apply_method", null)
      name         = parameter.value.name
      value        = parameter.value.name == "max_connections" ? local.rds_max_connections_per_type[parameter.value.value] : parameter.value.value
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}