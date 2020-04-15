resource "aws_s3_bucket" "this" {

  bucket        = lower(var.bucket)
  acl           = var.acl
  tags          = var.tags
  force_destroy = var.force_destroy

  dynamic "versioning" {
    for_each = length(keys(var.versioning)) == 0 ? [] : [var.versioning]

    content {
      enabled    = lookup(versioning.value, "enabled", null)
      mfa_delete = lookup(versioning.value, "mfa_delete", null)
    }
  }

  dynamic "cors_rule" {
    for_each = length(keys(var.cors_rule)) == 0 ? [] : [var.cors_rule]

    content {
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      allowed_headers = lookup(cors_rule.value, "allowed_headers", null)
      expose_headers  = lookup(cors_rule.value, "expose_headers", null)
      max_age_seconds = lookup(cors_rule.value, "max_age_seconds", null)
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }

}

resource "aws_s3_bucket_public_access_block" "this" {
  count  = var.acl == "private" && var.alb_access_logs_policy == false ? 1 : 0
  bucket = aws_s3_bucket.this.id

  block_public_acls   = true
  block_public_policy = true
}

data "aws_iam_policy_document" "this" {
  count = length(var.bucket_policy) > 0 ? 1 : 0
  dynamic "statement" {

    for_each = var.bucket_policy

    content {
      sid       = lookup(statement.value, "sid", null)
      effect    = lookup(statement.value, "effect", null)
      actions   = lookup(statement.value, "actions", null)
      resources = lookup(statement.value, "resources", null)

      dynamic "principals" {
        for_each = lookup(statement.value, "principals", null) == null ? [] : [1]

        content {
          type        = lookup(lookup(statement.value, "principals", null), "type", null)
          identifiers = lookup(lookup(statement.value, "principals", null), "identifiers", null)
        }
      }

      dynamic "condition" {
        for_each = lookup(statement.value, "condition", null) == null ? [] : [1]

        content {
          test     = lookup(lookup(statement.value, "condition", null), "test", null)
          variable = lookup(lookup(statement.value, "condition", null), "variable", null)
          values   = lookup(lookup(statement.value, "condition", null), "values", null)
        }
      }

    }

  }
}

resource "aws_s3_bucket_policy" "this" {
  count = length(var.bucket_policy) > 0 ? 1 : 0

  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.this[0].json
}

# ALB Access Logs policy

data "aws_elb_service_account" "this" {
  count = var.alb_access_logs_policy ? 1 : 0
}

data "aws_iam_policy_document" "alb_access_logs" {
  count = var.alb_access_logs_policy ? 1 : 0

  statement {
    principals {
      type        = "AWS"
      identifiers = data.aws_elb_service_account.this.*.arn
    }

    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.this.id}/*",
    ]
  }

  statement {

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.this.id}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = [
        "bucket-owner-full-control"
      ]
    }
  }

  statement {
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    effect = "Allow"

    actions = [
      "s3:GetBucketAcl",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.this.id}",
    ]
  }

}

resource "aws_s3_bucket_policy" "alb_access_logs" {
  count = var.alb_access_logs_policy ? 1 : 0

  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.alb_access_logs[0].json
}