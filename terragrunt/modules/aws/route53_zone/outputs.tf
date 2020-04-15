output "zone_id" {
  value = element(concat(aws_route53_zone.this.*.zone_id, list("")), 0)
}

output "name" {
  value = trimsuffix(element(concat(aws_route53_zone.this.*.name, list("")), 0), ".")
}

output "name_servers" {
  value = element(concat(aws_route53_zone.this.*.name_servers, list("")), 0)
}