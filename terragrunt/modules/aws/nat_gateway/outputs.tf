output "id" {
  value = concat(aws_nat_gateway.this.*.id, [""])[0]
}