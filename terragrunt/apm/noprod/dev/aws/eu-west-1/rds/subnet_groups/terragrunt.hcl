terraform {
  source = "${get_env("TG_ROOT_DIR", "/terragrunt")}/modules/aws//rds_subnet_group"
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
      Description = "Core Databases subnet group",
    }
  )
}

dependencies {
  paths = [
    "../../vpc/vpcs/vpc",
    "../../vpc/subnets/vpc_subnets"
  ]
}

dependency "vpc" {
  config_path = "../../vpc/vpcs/vpc"
  mock_outputs = {
    id = "fake-vpc_id"
  }
}

dependency "vpc_subnets" {
  config_path = "../../vpc/subnets/vpc_subnets"
  mock_outputs = {
    private_ids = ["fake-subnet-1", "fake-subnet-2", "fake-subnet-3"]
  }
}

inputs = {
  name       = "core-db-subnet-group"
  subnet_ids = dependency.vpc_subnets.outputs.private_ids

  # Tags are required (when possible)
  tags = local.tags
}