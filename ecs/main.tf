
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
    "${local.tag_names["creator"]}"     = "terraform"
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
//    low = "t2.micro"
    low    = "c5.large"
    medium = "c5.xlarge"
    high   = "c5.2xlarge"
  }
  ecs_additional_allowed_ec2_map = {
    low    = "2"
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
  //  desired_capacity     = local.cluster_desired_capacity
  tags       = data.null_data_source.tags.*.outputs
  depends_on = [aws_launch_configuration.cluster]
}

resource "aws_autoscaling_lifecycle_hook" "host_lifecycle_hook" {
  name                    = "${local.cluster_name}-tanium_aws_autoscaling_lifecycle_hook"
  autoscaling_group_name  = aws_autoscaling_group.cluster.name
  default_result          = "CONTINUE"
  heartbeat_timeout       = 1000
  lifecycle_transition    = "autoscaling:EC2_INSTANCE_TERMINATING"
  notification_target_arn = ""
  role_arn                = ""
  depends_on              = [aws_autoscaling_group.cluster]
}
################## AUTO SCALING ECS TASK ################################################
//resource "aws_ecs_capacity_provider" "cluster" {
//  //  name = "${local.cluster_name}-ecs-capacity-provider1"
//  name = aws_launch_configuration.cluster.name
//
//  auto_scaling_group_provider {
//    auto_scaling_group_arn         = aws_autoscaling_group.cluster.arn
//    managed_termination_protection = "DISABLED"
//
//    managed_scaling {
//      maximum_scaling_step_size = 1000
//      minimum_scaling_step_size = 1
//      status                    = "ENABLED"
//      target_capacity           = 80
//    }
//  }
//
//  depends_on = [aws_autoscaling_group.cluster]
//}
#-----------------------------------------------------------------------------------------

resource "aws_ecs_cluster" "cluster" {
  name               = local.cluster_name
//  capacity_providers = [aws_ecs_capacity_provider.cluster.name]
//  default_capacity_provider_strategy {
//    capacity_provider = aws_ecs_capacity_provider.cluster.name
//    base              = 2
//    weight            = 100
//  }

  depends_on = [
    null_resource.cloud_watch_wait,
//    aws_ecs_capacity_provider.cluster
  ]
}
#-----------------------------------------------------------------------------
locals {
//  cluster_name = "${var.application_name}-${var.environment}"
  aws_appautoscaling_policy_prefix = local.cluster_name
}

resource "aws_autoscaling_policy" "cpuClusterUp" {
  name                   = "${local.aws_appautoscaling_policy_prefix}-ScaleUp-CPU"
  scaling_adjustment     = 100
  adjustment_type        = "PercentChangeInCapacity"
//  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.cluster.name
  depends_on = [aws_autoscaling_group.cluster]
}

resource "aws_autoscaling_policy" "cpuClusterDown" {
  name                   = "${local.aws_appautoscaling_policy_prefix}-ScaleDown-CPU"
  scaling_adjustment     = -50
  adjustment_type        = "PercentChangeInCapacity"
//  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.cluster.name
  depends_on = [aws_autoscaling_group.cluster]
}

resource "aws_autoscaling_policy" "memClusterUp" {
  name                   = "${local.aws_appautoscaling_policy_prefix}-ScaleUp-MEM"
  scaling_adjustment     = 100
  adjustment_type        = "PercentChangeInCapacity"
//  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.cluster.name
  depends_on = [aws_autoscaling_group.cluster]
}

resource "aws_autoscaling_policy" "memClusterDown" {
  name                   = "${local.aws_appautoscaling_policy_prefix}-ScaleDown-MEM"
  scaling_adjustment     = -50
  adjustment_type        = "PercentChangeInCapacity"
//  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.cluster.name
  depends_on = [aws_autoscaling_group.cluster]
}

#-----------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "scaleClusterUpCPU" {
  alarm_name          = "${local.cluster_name}-scaleUp-CPU"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Average"
  threshold           = "75"
    dimensions = {
      AutoScalingGroupName = aws_autoscaling_group.cluster.name
    }
  alarm_description = "This metric monitors task cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.cpuClusterUp.arn]
}
resource "aws_cloudwatch_metric_alarm" "scaleClusterUpMemory" {
  alarm_name          = "${local.cluster_name}-scaleUp-Memory"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryReservation"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Average"
  threshold           = "75"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.cluster.name
  }
  alarm_description = "This metric monitors task memory utilization"
  alarm_actions     = [aws_autoscaling_policy.memClusterUp.arn]
}
resource "aws_cloudwatch_metric_alarm" "scaleClusterDownCPU" {
  alarm_name          = "${local.cluster_name}-scaleDown-CPU"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Average"
  threshold           = "25"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.cluster.name
  }
  alarm_description = "This metric monitors task cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.cpuClusterDown.arn]
}
resource "aws_cloudwatch_metric_alarm" "scaleClusterDownMemory" {
  alarm_name          = "${local.cluster_name}-scaleDown-Memory"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryReservation"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Average"
  threshold           = "25"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.cluster.name
  }
  alarm_description = "This metric monitors task memory utilization"
  alarm_actions     = [aws_autoscaling_policy.memClusterDown.arn]
}