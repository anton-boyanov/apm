terraform {
  source = "${get_env("TG_ROOT_DIR", "/terragrunt")}/modules/aws//acm_certificate"
}

include {
  path = find_in_parent_folders()
}

locals {
  common_vars = merge(
    yamldecode(file("${find_in_parent_folders("application.yaml")}")),
    yamldecode(file("${find_in_parent_folders("environment.yaml")}")),
    yamldecode(file("${find_in_parent_folders("provider.yaml")}")),
    yamldecode(file("${find_in_parent_folders("account.yaml")}")),
    yamldecode(file("${find_in_parent_folders("region.yaml")}")),
  )

  tags = merge({
    Application_name     = lookup(yamldecode(file("${find_in_parent_folders("application.yaml")}")), "application", ""),
    Environment          = lookup(yamldecode(file("${find_in_parent_folders("environment.yaml")}")), "environment", ""),
    Provider             = lookup(yamldecode(file("${find_in_parent_folders("provider.yaml")}")), "provider", ""),
    Account_id           = lookup(yamldecode(file("${find_in_parent_folders("account.yaml")}")), "account_id", ""),
    Region               = lookup(yamldecode(file("${find_in_parent_folders("region.yaml")}")), "region", ""),
    Confidentiality      = lookup(lookup(yamldecode(file("${find_in_parent_folders("application.yaml")}")), "static_resource_tags", ""), "confidentiality", ""),
    Owner                = lookup(lookup(yamldecode(file("${find_in_parent_folders("application.yaml")}")), "static_resource_tags", ""), "owner", ""),
    Created_by           = lookup(lookup(yamldecode(file("${find_in_parent_folders("application.yaml")}")), "static_resource_tags", ""), "created_by", ""),
    TG_resource_location = substr("${get_terragrunt_dir()}", 12, 0)
    },
    {
      # Always include description tag !!!
      Description = "Environment specific public internal DNS zone certificate"
    }
  )

}

dependencies {
  paths = [
    "../../../route_53/hosted_zones/internal_zone",
    "../../../../../${local.common_vars.root_aws_account_id}/${local.common_vars.region}/route_53/hosted_zones/top_domain_zone/internal_zone_ns_records",
  ]
}

dependency "internal_zone" {
  config_path = "../../../route_53/hosted_zones/internal_zone"

  mock_outputs = {
    zone_id = "fake-zone-id"
    name    = "internal.fakedomain.com."
  }
}

dependency "internal_zone_ns_records" {
  config_path = "../../../../../${local.common_vars.root_aws_account_id}/${local.common_vars.region}/route_53/hosted_zones/top_domain_zone/internal_zone_ns_records"

  mock_outputs = {
    created = "true"
  }
}

inputs = {
  domain_name = dependency.internal_zone.outputs.name

  create_dns_records = true
  automatic_cert_validation = true

  subject_alternative_names = [
    "*.${dependency.internal_zone.outputs.name}",
    "*.api.${dependency.internal_zone.outputs.name}",
    "*.rest.${dependency.internal_zone.outputs.name}",
    "*.grpc.${dependency.internal_zone.outputs.name}",
    "*.db.${dependency.internal_zone.outputs.name}",
    "*.ro-db.${dependency.internal_zone.outputs.name}",
    "*.health.${dependency.internal_zone.outputs.name}",
  ]

  zone_id = dependency.internal_zone.outputs.zone_id

  # Tags are required (when possible)
  tags = local.tags
}