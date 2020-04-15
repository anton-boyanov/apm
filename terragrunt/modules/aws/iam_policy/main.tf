data "aws_iam_policy_document" "this" {

  dynamic "statement" {

    for_each = var.statements

    content {
      actions   = lookup(statement.value, "actions", null)
      resources = lookup(statement.value, "resources", null)
    }
  }
}

resource "aws_iam_policy" "this" {
  name   = var.name
  policy = data.aws_iam_policy_document.this.json
}