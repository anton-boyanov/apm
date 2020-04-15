resource "aws_autoscaling_group" "this" {
  name = "${var.cluster_name}-asg"

  launch_template {
    id      = var.launch_template_id
    version = "$Latest"
  }

  desired_capacity = var.desired_capacity
  min_size         = var.min_size
  max_size         = var.max_size

  health_check_type         = "EC2"
  health_check_grace_period = "300"

  termination_policies = [
    "OldestLaunchConfiguration",
    "OldestInstance",
    "Default",
  ]

  vpc_zone_identifier = var.vpc_subnets

  default_cooldown = 120

  dynamic "tag" {
    for_each = var.tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }

  }

}

resource "aws_autoscaling_policy" "memory_autoscaling_policy" {
  count = var.enable_memory_autoscaling_policy == true ? 1 : 0

  name = "${var.cluster_name}-memory"

  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.this.name

  target_tracking_configuration {
    customized_metric_specification {
      metric_dimension {
        name  = "ClusterName"
        value = var.cluster_name
      }

      metric_name = "MemoryReservation"
      namespace   = "AWS/ECS"
      statistic   = "Average"
    }

    target_value     = 70
    disable_scale_in = false
  }
}

resource "aws_autoscaling_policy" "cpu_autoscaling_policy" {
  count = var.enable_cpu_autoscaling_policy == true ? 1 : 0

  name = "${var.cluster_name}-CPU"

  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.this.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value     = 70
    disable_scale_in = false
  }
}

resource "aws_autoscaling_policy" "container_count_autoscaling_policy" {
  count = var.enable_containers_count_autoscaling_policy == true ? 1 : 0

  name = "${var.cluster_name}-ContainersCount"

  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.this.name

  target_tracking_configuration {
    customized_metric_specification {
      metric_dimension {
        name  = "ClusterName"
        value = var.cluster_name
      }

      metric_name = "Docker Running Container Count"
      namespace   = "System/Linux"
      statistic   = "Average"
    }

    target_value     = 7
    disable_scale_in = false
  }
}