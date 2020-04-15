output "id" {
  value = element(concat(aws_default_security_group.this.*.id, list("")), 0)
}