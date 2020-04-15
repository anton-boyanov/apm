output "arn" {
  value = element(concat(aws_acm_certificate.this.*.arn, list("")), 0)
}

output "domain_validation_options" {
  value = aws_acm_certificate.this.domain_validation_options
}

output "domain_name" {
  value = aws_acm_certificate.this.domain_name
}
