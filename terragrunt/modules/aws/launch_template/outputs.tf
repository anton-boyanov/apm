output "id" {
  value = concat(aws_launch_template.this.*.id, [""])[0]
}

output "arn" {
  value = concat(aws_launch_template.this.*.arn, [""])[0]
}