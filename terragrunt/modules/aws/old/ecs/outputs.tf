output "ecs_cluster_id" {
  value = aws_ecs_cluster.cluster.id
}
output "tags" {
  value = local.tags
}
output "tag_names" {
  value = local.tag_names
}
output "merged_cluster_tags" {
  value = local.merged_cluster_tags
}