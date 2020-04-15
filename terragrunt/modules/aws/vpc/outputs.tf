output "name" {
  value = var.tags.Name
}

output "id" {
  value = concat(aws_vpc.this.*.id, [""])[0]
}

output "arn" {
  value = concat(aws_vpc.this.*.arn, [""])[0]
}

output "cidr_block" {
  value = concat(aws_vpc.this.*.cidr_block, [""])[0]
}

output "default_route_table_id" {
  value = concat(aws_vpc.this.*.default_route_table_id, [""])[0]
}

output "default_security_group_id" {
  value = concat(aws_vpc.this.*.default_security_group_id, [""])[0]
}

output "default_network_acl_id" {
  value = concat(aws_vpc.this.*.default_network_acl_id, [""])[0]
}