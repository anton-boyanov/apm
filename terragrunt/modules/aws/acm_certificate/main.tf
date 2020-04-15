locals {
  distinct_domain_names = distinct(concat([var.domain_name], [for s in var.subject_alternative_names : replace(s, "*.", "")]))
  validation_domains    = [for k, v in aws_acm_certificate.this.domain_validation_options : tomap(v) if contains(local.distinct_domain_names, replace(v.domain_name, "*.", ""))]
}

resource "aws_acm_certificate" "this" {
  domain_name               = trimsuffix(var.domain_name, ".")
  subject_alternative_names = var.subject_alternative_names
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.tags,
    {
      Name = var.domain_name
    }
  )
}

resource "aws_route53_record" "this" {
  count = var.create_dns_records == true ? (length(local.distinct_domain_names) + 1) : 0

  zone_id         = var.zone_id
  name            = element(local.validation_domains, count.index)["resource_record_name"]
  type            = element(local.validation_domains, count.index)["resource_record_type"]
  ttl             = 60
  allow_overwrite = true

  records = [
    element(local.validation_domains, count.index)["resource_record_value"]
  ]

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_acm_certificate.this]
}

resource "aws_acm_certificate_validation" "this" {
  count = var.automatic_cert_validation == true ? 1 : 0
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = aws_route53_record.this.*.fqdn
}
