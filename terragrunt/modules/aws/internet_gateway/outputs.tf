output "id" {
  value = concat(aws_internet_gateway.this.*.id, [""])[0]
}
