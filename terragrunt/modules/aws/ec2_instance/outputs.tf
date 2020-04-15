
output "id" {
  value = aws_instance.this.*.id
}

output "arn" {
  value = aws_instance.this.*.arn
}

output "public_dns" {
  value = aws_instance.this.*.public_dns
}

output "public_ip" {
  value = aws_instance.this.*.public_ip
}

output "primary_network_interface_id" {
  value = aws_instance.this.*.primary_network_interface_id
}

output "private_dns" {
  value = aws_instance.this.*.private_dns
}

output "private_ip" {
  value = aws_instance.this.*.private_ip
}