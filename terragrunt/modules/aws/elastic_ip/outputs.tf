output "id" {
  value = element(concat(aws_eip.this.*.id, list("")), 0)
}

output "public_ip" {
  value = element(concat(aws_eip.this.*.public_ip, list("")), 0)
}