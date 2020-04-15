output "fqdns" {
  value = element(concat(aws_route53_record.this.*.fqdn, list("")), 0)
}