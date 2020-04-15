data "aws_availability_zones" "this" {
  state = "available"
}

resource "aws_rds_cluster" "this" {
  cluster_identifier        = var.identifier
  availability_zones        = data.aws_availability_zones.this.names
  master_username           = var.master_username
  master_password           = local.password
  engine                    = var.engine
  engine_version            = var.engine_version
  engine_mode               = var.engine_mode
  vpc_security_group_ids    = var.vpc_security_group_ids
  db_subnet_group_name      = var.db_subnet_group_name
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot == "false" ? var.final_snapshot_identifier : null
  copy_tags_to_snapshot     = var.copy_tags_to_snapshot
  storage_encrypted         = var.encrypted
  backup_retention_period   = var.backup_retention_period
  apply_immediately         = var.apply_immediately

  db_cluster_parameter_group_name = var.rds_cluster_param_group_name

  deletion_protection = var.deletion_protection

  dynamic "scaling_configuration" {
    for_each = var.scaling_configuration
    content {
      auto_pause               = lookup(scaling_configuration.value, "auto_pause", null)
      max_capacity             = lookup(scaling_configuration.value, "max_capacity", null)
      min_capacity             = lookup(scaling_configuration.value, "min_capacity", null)
      seconds_until_auto_pause = lookup(scaling_configuration.value, "seconds_until_auto_pause", null)
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.identifier}-cluster"
    }
  )
}

resource "aws_rds_cluster_instance" "db_instance" {
  count = var.num_instances

  identifier              = "${var.identifier}-${count.index}"
  cluster_identifier      = aws_rds_cluster.this.cluster_identifier
  instance_class          = var.instance_type
  publicly_accessible     = var.publicly_accessible
  engine                  = aws_rds_cluster.this.engine
  engine_version          = aws_rds_cluster.this.engine_version
  db_parameter_group_name = var.rds_db_param_group_name
  monitoring_role_arn     = var.rds_monitoring_role_arn
  monitoring_interval     = var.monitoring_interval #60

  depends_on = [aws_rds_cluster.this]

  tags = merge(
    var.tags,
    {
      Name = "${var.identifier}-cluster-instance-${count.index}"
    }
  )
}

### Create password and save it in 1Password ###

locals {
  # During the development we'll use ENV as a prefix
  # title = var.identifier - for FINAL version
  title    = var.identifier == "" ? var.identifier : "${var.environment}-${var.identifier}"
  user     = var.master_username
  password = data.external.secret.result["password"]
}

# Null resource used for the creation of the secret and the whole integration TF <-> 1Password
resource "null_resource" "secret" {

  # Tricky way to tell Terraform to recreate the null object every time
  triggers = {
    always_run = timestamp()
  }

  # Creates the record
  provisioner "local-exec" {
    when = create

    command     = "/app/op.sh create \"database\" \"${local.title}\" \"${local.title}\" \"${local.user}\""
    interpreter = ["bash", "-c"]
  }

  # The record is going to be deleted on "terraform destroy"
  provisioner "local-exec" {
    when = destroy

    command     = "/app/op.sh delete \"${local.title}\""
    interpreter = ["bash", "-c"]
  }
}

data "external" "secret" {
  program = ["bash", "/app/op.sh"]

  query = {
    action = "get"
    type   = "database"
    title  = local.title
  }

  depends_on = [null_resource.secret]
}