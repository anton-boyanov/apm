output "es_domain_arn" {
  value = aws_elasticsearch_domain.this.arn
}

output "es_domain_endpoint" {
  value = aws_elasticsearch_domain.this.endpoint
}

output "domain_name" {
  value = var.domain_name
}