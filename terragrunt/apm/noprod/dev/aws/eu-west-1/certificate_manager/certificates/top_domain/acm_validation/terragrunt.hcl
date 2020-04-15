terraform {
  source = "${get_env("TG_ROOT_DIR", "/terragrunt")}/modules/aws//acm_validation"
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
  # Tags are not supported here!
}


dependencies {
  paths = [
    "../../../../../../${local.common_vars.root_aws_account_id}/${local.common_vars.region}/route_53/hosted_zones/top_domain_zone/top_domain_cert_cname_records",
    "../acm_request"
  ]
}

dependency "top_domain_cert_cname_records" {
  config_path = "../../../../../../${local.common_vars.root_aws_account_id}/${local.common_vars.region}/route_53/hosted_zones/top_domain_zone/top_domain_cert_cname_records"

  mock_outputs = {
    fqdns = "_0b3c3afe52b.fakedomain.com"
  }
}

dependency "acm_request" {
  config_path = "../acm_request"

  mock_outputs = {
    arn = "arn:aws:acm:fake-region:123456:certificate/fake-11111-2222-3333"
  }
}

inputs = {
  certificate_arn = dependency.acm_request.outputs.arn
  validation_record_fqdns = [dependency.top_domain_cert_cname_records.outputs.fqdns]
}