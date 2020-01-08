locals {
  alb_name           = "${var.application_name}-${var.environment}-${var.service_name}-alb"
  container_port     = var.container_port
  container_protocol = var.container_protocol
  alb_port           = var.alb_port
  alb_protocol       = var.alb_protocol
}

module "log_group" {
  source                        = "../logs_service"
  cloud_watch_retention_in_days = var.cloud_watch_retention_in_days
  log_group                     = var.service_name
  merged_cluster_tags           = var.merged_cluster_tags
  application_name              = var.application_name
  environment                   = var.environment
}
#-------------------------------------------------- IAM Cluster Service Role
//data "aws_iam_role" "cluster_service_role" {
//  //  name = "${local.cluster_name}-cluster-service-role"
//  name = "terraform-20190926194703502800000001"
//}

# -----ALB-------------------

resource "aws_alb" "alb" {
  name            = local.alb_name
  internal        = var.internal
  subnets         = var.subnets
  security_groups = [var.alb_security_group]
  enable_http2    = "true"
  idle_timeout    = 720
  tags            = merge(map(var.tag_names["name"], local.alb_name), var.merged_cluster_tags)
}

#-------------------------------------------------- Get public domain
//data "aws_route53_zone" "public_domain" {
//  name         = "${var.domain}."
//  private_zone = false
//}

#-------------------------------------------------- Get SSL cert from ACM for public domain.

//data "aws_acm_certificate" "public_ssl_cert" {
//  domain = "*.${var.domain}"
//  statuses = ["ISSUED"]
//}

//resource "aws_route53_record" "public_record" {
//  zone_id = data.aws_route53_zone.public_domain.zone_id
//  name    = "${var.service_name}.${var.domain}"
//  type    = "A"
//
//  alias {
//    name                   = aws_alb.alb.dns_name
//    zone_id                = aws_alb.alb.zone_id
//    evaluate_target_health = false
//  }
//  depends_on = [aws_alb.alb]
//}
# -----TARGET GROUP------------------

resource "aws_alb_target_group" "target_group" {
  /* prefix can only be max 6 characters */
  name_prefix = var.target_group_prefix
  port        = local.alb_port
  protocol    = local.alb_protocol
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  health_check {
    interval            = "120"
    path                = "/"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 60
    protocol            = var.container_protocol
    matcher             = "200"
  }

  tags       = var.tags
  depends_on = [aws_alb.alb]
}

# -----LISTENER------------------

resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = var.alb_port
  protocol          = var.alb_protocol
  #TODO
  ##ssl_policy        = "ELBSecurityPolicy-2016-08"
  ##certificate_arn   = var.certificate.arn

  default_action {
    target_group_arn = aws_alb_target_group.target_group.arn
    type             = "forward"
  }
  depends_on = [aws_alb.alb]
}

data "template_file" "container_definition" {
  template = file("${path.module}/task_definition/container_definition.json")

  vars = {
    environment = jsonencode(var.environment_variables)
    //    image                 = "${var.apm_ecr_url}/${var.application_name}-${var.service_name}-service:${var.docker_tag}"
    image                 = "store/elastic/filebeat:${var.docker_tag}" #TODO
    name                  = "${var.application_name}-${var.environment}-${var.service_name}"
    containerPort         = local.container_port
    awslogs-group         = module.log_group.log_group
    awslogs-region        = var.aws_region_name
    awslogs-stream-prefix = var.service_name
  }
}

# -----TASK DEFENITION------------------

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                = "${var.application_name}-${var.environment}-${var.service_name}"
  container_definitions = data.template_file.container_definition.rendered
//  task_role_arn         = "arn:aws:iam::791550111152:role/apm-configuration-svc-role"
  network_mode          = "bridge"
}

resource "null_resource" "alb_exists" {
  triggers = {
    lb_name = local.alb_name
  }
}

# -----SERVICE------------------


resource "aws_ecs_service" "ecs_service" {
  name                               = aws_ecs_task_definition.ecs_task_definition.family
  cluster                            = var.ecs_cluster_id #data.aws_ecs_cluster.ecs_cluster.arn
  task_definition                    = aws_ecs_task_definition.ecs_task_definition.arn
  scheduling_strategy = var.scheduling_strategy
  deployment_minimum_healthy_percent = "100"
  deployment_maximum_percent         = "200"
  health_check_grace_period_seconds  = "240"
  //  iam_role                           = "arn:aws:iam::791550111152:role/terraform-20190926194703502800000001"
//    iam_role   = data.aws_iam_role.cluster_service_role.arn
  iam_role   = var.ecs_service_role
  depends_on = ["null_resource.alb_exists"]

  load_balancer {
    target_group_arn = aws_alb_target_group.target_group.arn
    container_name   = aws_ecs_task_definition.ecs_task_definition.family
    container_port   = var.container_port
  }
}