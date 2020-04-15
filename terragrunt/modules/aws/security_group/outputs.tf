output "id" {
  value = element(concat(aws_security_group.this.*.id, list("")), 0)
}

output "arn" {
  value = element(concat(aws_security_group.this.*.arn, list("")), 0)
}