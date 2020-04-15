output "role_id" {
  value = element(concat(aws_iam_role.this.*.id, list("")), 0)
}

output "role_arn" {
  value = element(concat(aws_iam_role.this.*.arn, list("")), 0)
}

output "instance_profile_id" {
  value = element(concat(aws_iam_instance_profile.this.*.id, list("")), 0)
}

output "instance_profile_arn" {
  value = element(concat(aws_iam_instance_profile.this.*.arn, list("")), 0)
}

output "instance_profile_name" {
  value = element(concat(aws_iam_instance_profile.this.*.name, list("")), 0)
}