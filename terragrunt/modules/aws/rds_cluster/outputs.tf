output "arn" {
  value = aws_rds_cluster.this.arn
}

output "id" {
  value = aws_rds_cluster.this.id
}

output "endpoint" {
  description = "The DNS address of the RDS instance"
  value       = aws_rds_cluster.this.endpoint
}

output "database_name" {
  value = aws_rds_cluster.this.database_name
}