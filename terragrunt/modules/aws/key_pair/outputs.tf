output "id" {
  value = concat(aws_key_pair.this.*.key_pair_id, [""])[0]
}

output "name" {
  value = concat(aws_key_pair.this.*.key_name, [""])[0]
}
