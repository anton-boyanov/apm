data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

data "template_file" "user_data" {
  count = length(var.user_data) > 0 ? 1 : 0

  template = file(var.user_data)
  vars     = var.user_data_vars
}

resource "aws_launch_template" "this" {
  name = "${var.name_prefix}-launch-template"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.volume_size
      volume_type           = "gp2"
      delete_on_termination = true
      encrypted             = true
    }
  }

  ebs_optimized = false

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  image_id = data.aws_ssm_parameter.ecs_ami.value

  instance_initiated_shutdown_behavior = "terminate"

  instance_type = var.instance_type

  key_name = var.key_name

  monitoring {
    enabled = true
  }

  vpc_security_group_ids = var.vpc_security_group_ids

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.tags,
      {
        Name        = "${var.name_prefix}-instance"
        Description = "${var.name_prefix} Instance"
      }
    )

  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      var.tags,
      {
        Name        = "${var.name_prefix}-volume"
        Description = "${var.name_prefix} Volume"
      }
    )
  }

  user_data = length(var.user_data) > 0 ? base64encode(data.template_file.user_data[0].rendered) : null
}
