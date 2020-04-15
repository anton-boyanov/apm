output "id" {
  value = element(concat(aws_route_table.this.*.id, list("")), 0)
}