output "id" {
  value = element(concat(aws_ecs_cluster.this.*.id, list("")), 0)
}

output "arn" {
  value = element(concat(aws_ecs_cluster.this.*.arn, list("")), 0)
}

output "name" {
  value = var.name
}