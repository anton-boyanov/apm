data "aws_iam_policy_document" "assume_role_policy_document" {
  dynamic "statement" {

    for_each = var.assume_role_policy

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

    }

  }
}

resource "aws_iam_role" "this" {
  name               = "${var.name_prefix}-role"
  path               = var.path
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_document.json
}

data "aws_iam_policy_document" "role_policy_document" {

  dynamic "statement" {

    for_each = var.role_policy_document

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


    }

  }
}

resource "aws_iam_role_policy" "this" {
  name   = "${var.name_prefix}-role-policy"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.role_policy_document.json
}

resource "aws_iam_instance_profile" "this" {
  count = var.iam_istance_profile == true ? 1 : 0
  name  = "${var.name_prefix}-instance-profile"
  role  = aws_iam_role.this.name
}