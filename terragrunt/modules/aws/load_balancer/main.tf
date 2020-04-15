resource "aws_lb" "this" {
  name = var.name

  load_balancer_type = var.load_balancer_type
  internal           = var.internal
  security_groups    = var.security_groups
  subnets            = var.subnets

  idle_timeout                     = var.idle_timeout
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  enable_deletion_protection       = var.enable_deletion_protection
  enable_http2                     = var.enable_http2
  ip_address_type                  = var.ip_address_type

  dynamic "access_logs" {
    for_each = length(keys(var.access_logs)) == 0 ? [] : [var.access_logs]

    content {
      enabled = lookup(access_logs.value, "enabled", lookup(access_logs.value, "bucket", null) != null)
      bucket  = lookup(access_logs.value, "bucket", null)
      prefix  = lookup(access_logs.value, "prefix", null)
    }
  }

  dynamic "subnet_mapping" {
    for_each = var.subnet_mapping

    content {
      subnet_id     = subnet_mapping.value.subnet_id
      allocation_id = lookup(subnet_mapping.value, "allocation_id", null)
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )

  timeouts {
    create = var.load_balancer_create_timeout
    update = var.load_balancer_update_timeout
    delete = var.load_balancer_delete_timeout
  }
}


resource "aws_lb_listener" "tcp_http" {
  count = length(var.tcp_http_listeners) > 0 ? length(var.tcp_http_listeners) : 0

  load_balancer_arn = aws_lb.this.arn

  port     = var.tcp_http_listeners[count.index]["port"]
  protocol = var.tcp_http_listeners[count.index]["protocol"]

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = ""
      status_code  = "400"
    }
  }
}

resource "aws_lb_listener" "https" {
  count = length(var.https_listeners) > 0 ? length(var.https_listeners) : 0

  load_balancer_arn = aws_lb.this.arn

  port            = var.https_listeners[count.index]["port"]
  protocol        = lookup(var.https_listeners[count.index], "protocol", "HTTPS")
  certificate_arn = var.https_listeners[count.index]["certificate_arn"]
  ssl_policy      = lookup(var.https_listeners[count.index], "ssl_policy", var.listener_ssl_policy_default)

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = ""
      status_code  = "400"
    }
  }

}

resource "aws_lb_listener_certificate" "https_listener_certificate" {
  count = length(var.extra_ssl_certs) > 0 ? length(var.extra_ssl_certs) : 0

  listener_arn    = aws_lb_listener.https[var.extra_ssl_certs[count.index]["https_listener_index"]].arn
  certificate_arn = var.extra_ssl_certs[count.index]["certificate_arn"]
}