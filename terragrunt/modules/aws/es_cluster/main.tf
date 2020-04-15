resource "aws_elasticsearch_domain" "this" {
  domain_name           = var.domain_name
  elasticsearch_version = var.elasticsearch_version

  encrypt_at_rest {
    enabled              = var.encrypted
  }

  cluster_config {
    instance_type          = var.instance_type
    instance_count         = var.instance_count
    zone_awareness_enabled = var.zone_awareness_enabled

    zone_awareness_config {
      availability_zone_count = var.availability_zone_count
    }
  }

  ebs_options {
    ebs_enabled = var.ebs_enabled
    volume_size = var.volume_size
  }

  snapshot_options {
    automated_snapshot_start_hour = var.automated_snapshot_start_hour
  }

  vpc_options {
    subnet_ids         = slice(var.subnet_ids, 0,  var.instance_count)
    security_group_ids = var.security_group_ids
  }

  tags = merge(
    var.tags,
    {
      Name = var.domain_name
    }
   )
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = ["es:*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources =  ["${aws_elasticsearch_domain.this.arn}/*"]
  }
}


resource "aws_elasticsearch_domain_policy" "this" {
  domain_name = var.domain_name
  access_policies = data.aws_iam_policy_document.this.json
}