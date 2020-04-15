locals {
  distinct_records = distinct([for s in var.domain_validation_options : s.resource_record_name])
}

resource "aws_route53_record" "this" {
  count                            = length(local.distinct_records)
  name                             = lookup(var.domain_validation_options[count.index], "resource_record_name")
  type                             = lookup(var.domain_validation_options[count.index], "resource_record_type")
  zone_id                          = var.zone_id
  ttl                              = 60
  records                          = [lookup(var.domain_validation_options[count.index], "resource_record_value")]
}