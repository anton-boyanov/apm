resource "aws_elasticache_replication_group" "this" {
  auth_token                    = var.transit_encryption_enabled ? var.auth_token : null
  replication_group_id          = var.replication_group_id
  replication_group_description = var.tags.Description
  node_type                     = var.instance_type
  number_cache_clusters         = var.cluster_mode_enabled ? (1 + var.cluster_mode_replicas_per_node_group) * var.cluster_mode_num_node_groups : var.cluster_size
  port                          = var.port
  availability_zones            = slice(var.availability_zones, 0, var.cluster_size)
  automatic_failover_enabled    = var.automatic_failover_enabled
  subnet_group_name             = var.subnet_group_name
  security_group_ids            = var.security_group_ids
  maintenance_window            = var.maintenance_window
  engine_version                = var.engine_version
  at_rest_encryption_enabled    = var.at_rest_encryption_enabled
  transit_encryption_enabled    = var.transit_encryption_enabled
  snapshot_window               = var.snapshot_window
  snapshot_retention_limit      = var.snapshot_retention_limit
  apply_immediately             = var.apply_immediately

  dynamic "cluster_mode" {
    for_each = var.cluster_mode_enabled ? ["true"] : []
    content {
      replicas_per_node_group = var.cluster_mode_replicas_per_node_group
      num_node_groups         = var.cluster_mode_num_node_groups
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.replication_group_id
    }
  )
}

//resource "aws_route53_record" "java_backend_redis" {
//  zone_id = "${var.core_internal_zone_id}"
//
//  name    = "java-backend.redis"
//  type    = "CNAME"
//  ttl     = 120
//  records = ["${aws_elasticache_cluster.java_backend_redis.cache_nodes.0.address}"]
//}