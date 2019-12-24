
locals {
  cloud_watch_path = "${var.application_name}/${var.environment}"
  merged_cluster_tags = var.merged_cluster_tags
}

resource "aws_cloudwatch_log_group" "cluster" {
  name              = "${local.cloud_watch_path}/var/log/cluster"
  tags              = local.merged_cluster_tags
  retention_in_days = var.cloud_watch_retention_in_days
}

resource "aws_cloudwatch_log_group" "dmesg" {
  name              = "${local.cloud_watch_path}/var/log/dmesg"
  tags              = local.merged_cluster_tags
  retention_in_days = var.cloud_watch_retention_in_days
}

resource "aws_cloudwatch_log_group" "docker" {
  name              = "${local.cloud_watch_path}/var/log/docker"
  tags              = local.merged_cluster_tags
  retention_in_days = var.cloud_watch_retention_in_days
}

resource "aws_cloudwatch_log_group" "ecs-agent" {
  name              = "${local.cloud_watch_path}/var/log/ecs/ecs-agent.log"
  tags              = local.merged_cluster_tags
  retention_in_days = var.cloud_watch_retention_in_days
}

resource "aws_cloudwatch_log_group" "ecs-init" {
  name              = "${local.cloud_watch_path}/var/log/ecs/ecs-init.log"
  tags              = local.merged_cluster_tags
  retention_in_days = var.cloud_watch_retention_in_days
}

resource "aws_cloudwatch_log_group" "audit" {
  name              = "${local.cloud_watch_path}/var/log/ecs/audit.log"
  tags              = local.merged_cluster_tags
  retention_in_days = var.cloud_watch_retention_in_days
}

resource "aws_cloudwatch_log_group" "messages" {
  name              = "${local.cloud_watch_path}/var/log/messages"
  tags              = local.merged_cluster_tags
  retention_in_days = var.cloud_watch_retention_in_days
}

resource "aws_cloudwatch_log_group" "ssm-agent" {
  name              = "${local.cloud_watch_path}/var/log/amazon/ssm/amazon-ssm-agent.log"
  tags              = local.merged_cluster_tags
  retention_in_days = var.cloud_watch_retention_in_days
}

resource "aws_cloudwatch_log_group" "ssm-agent-errors" {
  name              = "${local.cloud_watch_path}/var/log/amazon/ssm/errors.log"
  tags              = local.merged_cluster_tags
  retention_in_days = var.cloud_watch_retention_in_days
}