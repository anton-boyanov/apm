locals {
  cloud_watch_path = "${var.application_name}/${var.environment}"
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "${local.cloud_watch_path}/${var.log_group}"
  tags              = var.merged_cluster_tags
  retention_in_days = var.cloud_watch_retention_in_days
}