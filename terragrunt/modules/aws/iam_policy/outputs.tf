output "id" {
  value = element(concat(aws_iam_policy.this.*.id, list("")), 0)
}

output "arn" {
  value = element(concat(aws_iam_policy.this.*.arn, list("")), 0)
}