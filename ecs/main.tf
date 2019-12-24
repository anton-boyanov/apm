
resource "null_resource" "cloud_watch_wait" {
  depends_on = [
    var.log_group_cluster,
    var.log_group_dmesg,
    var.log_group_docker,
    var.log_group_ecs_agent,
    var.log_group_ecs_init,
    var.log_group_audit,
    var.log_group_messages,
    var.log_group_ssm_agent_errors,
    var.log_group_ssm_agent,
  ]

  provisioner "local-exec" {
    command = "sleep 30"
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = [
    "amazon",
  ]

  filter {
    name = "name"

    values = [
      "amzn-ami-*-amazon-ecs-optimized",
    ]
  }
}
#-------------------------------------------------- IAM Cluster Instance Role
//data "aws_iam_role" "cluster_instance_role" {
//  //  name = "${local.cluster_name}-cluster-instance-role"
//  name = "terraform-20190926194703502900000002"
//}

data "template_file" "cluster_user_data" {
  /* What if someone passed in template and they do not include the 'ECS_CLUSTER'? */
  template = file("${path.module}/user-data/cluster.tpl")

  vars = {
    cluster_name        = local.cluster_name
    cloudwatch_prefix   = local.cloud_watch_path
    custom_userdata     = ""
    network_mode        = "bridge"
    service_restriction = "none"
  }
}

data "null_data_source" "tags" {
  count = local.merged_cluster_instance_tags_count - 1

  inputs = {
    key                 = keys(local.merged_cluster_instance_tags)[count.index]
    value               = values(local.merged_cluster_instance_tags)[count.index]
    propagate_at_launch = true
  }
}
locals {
  cluster_tags_count          = "1"
  cluster_instance_tags_count = "1"
  tag_names = {
    environment  = "Environment"
    application  = "Application"
    creator      = "Creator"
    name         = "Name"
    cluster_name = "Cluster Name"
  }
  tags = {
    "${local.tag_names["environment"]}" = var.environment
    "${local.tag_names["application"]}" = var.application_name
    "${local.tag_names["creator"]}"    = "terraform"
  }
  cluster_tags = {
    "${local.tag_names["cluster_name"]}" = local.cluster_name
  }
  cluster_instance_tags = {
    "${local.tag_names["name"]}" = local.cluster_name
  }
  merged_cluster_tags                = merge(local.cluster_instance_tags, local.tags)
  merged_cluster_tags_count          = local.cluster_instance_tags_count + length(local.tags)
  merged_cluster_instance_tags       = merge(local.cluster_instance_tags, local.merged_cluster_tags)
  merged_cluster_instance_tags_count = local.cluster_instance_tags_count + local.merged_cluster_tags_count


  tasks_per_service_map = {
    low    = "1"
    medium = local.number_of_availability_zones
    high   = local.number_of_availability_zones * 2
  }
  number_of_availability_zones = min(var.max_availability_zones, length(var.subnet_ids))
  tasks_per_service            = lookup(local.tasks_per_service_map, var.performance_level)
}
locals {
  ecs_instance_type_map = {
    low    = "c5.large"
    medium = "c5.xlarge"
    high   = "c5.2xlarge"
  }
  ecs_additional_allowed_ec2_map = {
    low    = "1"
    medium = var.enough_instances_per_cluster
    high   = var.enough_instances_per_cluster
  }
  ecs_minimum_ec2_map = {
    low    = var.enough_instances_per_cluster
    medium = var.enough_instances_per_cluster * local.number_of_availability_zones
    high   = var.enough_instances_per_cluster * local.number_of_availability_zones * 2
  }
  ecs_instance_type          = lookup(local.ecs_instance_type_map, var.performance_level)
  ecs_minimum                = lookup(local.ecs_minimum_ec2_map, var.performance_level)
  ecs_additional_allowed_ec2 = lookup(local.ecs_additional_allowed_ec2_map, var.performance_level)

  cluster_instance_docker_block_device_size = 100
  cluster_instance_docker_block_device_name = "/dev/xvdcz"
  cluster_instance_root_block_device_size   = 10
  cluster_minimum_size                      = lookup(local.ecs_minimum_ec2_map, var.performance_level)
  cluster_maximum_size                      = local.ecs_minimum + local.ecs_additional_allowed_ec2
  cluster_desired_capacity                  = local.ecs_minimum
}

locals {
  cluster_name     = "${var.application_name}-${var.environment}"
  cloud_watch_path = "${var.application_name}/${var.environment}"
}

resource "aws_ecs_cluster" "cluster" {
  name = local.cluster_name

  depends_on = [
    "null_resource.cloud_watch_wait"
  ]
}

resource "aws_launch_configuration" "cluster" {
  name_prefix   = "${local.cluster_name}-lc-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = local.ecs_instance_type
  key_name      = var.key_name
  //  iam_instance_profile        = "${local.cluster_name}-cluster-instance-profile"
  iam_instance_profile        = var.iam_instance_profile
  user_data                   = data.template_file.cluster_user_data.rendered
  security_groups             = [var.security_group]
  associate_public_ip_address = false

  root_block_device {
    volume_size = local.cluster_instance_root_block_device_size
  }

  ebs_block_device {
    device_name = local.cluster_instance_docker_block_device_name
    volume_size = local.cluster_instance_docker_block_device_size
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "cluster" {
  name                = local.cluster_name
  vpc_zone_identifier = var.subnets
  //  vpc_zone_identifier  = slice(local.app_subnets_ids_sorted_by_az_name, 0, min(var.max_availability_zones, length(local.app_subnets_ids_sorted_by_az_name)))
  launch_configuration = aws_launch_configuration.cluster.name
  min_size             = local.cluster_minimum_size
  max_size             = local.cluster_maximum_size
  desired_capacity     = local.cluster_desired_capacity
  tags                 = data.null_data_source.tags.*.outputs
}

resource "aws_autoscaling_lifecycle_hook" "host_lifecycle_hook" {
  name                    = "${local.cluster_name}-tanium_aws_autoscaling_lifecycle_hook"
  autoscaling_group_name  = aws_autoscaling_group.cluster.name
  default_result          = "CONTINUE"
  heartbeat_timeout       = 1000
  lifecycle_transition    = "autoscaling:EC2_INSTANCE_TERMINATING"
  notification_target_arn = ""
  role_arn                = ""
}