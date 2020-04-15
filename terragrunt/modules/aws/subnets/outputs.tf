output "all_ids" {
  value = concat(aws_subnet.private.*.id, aws_subnet.public.*.id)
}

output "private_ids" {
  value = aws_subnet.private.*.id
}

output "public_ids" {
  value = aws_subnet.public.*.id
}

output "all_cidr_blocks" {
  value = concat(aws_subnet.private.*.cidr_block, aws_subnet.public.*.cidr_block)
}

output "private_cidr_blocks" {
  value = aws_subnet.private.*.cidr_block
}

output "public_cidr_blocks" {
  value = aws_subnet.public.*.cidr_block
}