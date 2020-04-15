output "id" {
  value = element(concat(aws_default_network_acl.this.*.id, list("")), 0)
}