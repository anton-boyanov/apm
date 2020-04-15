terraform {
  source = "${get_env("TG_ROOT_DIR", "/terragrunt")}/modules/aws//security_group"
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
      Description = "backend-db-57 Security Group",
    }
  )
}

dependencies {
  paths = ["../../vpcs/vpc"]
}

dependency "vpc" {
  config_path = "../../vpcs/vpc"
  mock_outputs = {
    id         = "fake-vpc-id"
    name       = "fake-vpc-name"
    cidr_block = "10.16.1.0/24"
  }
}

inputs = {
  vpc_id      = dependency.vpc.outputs.id
  vpc_name    = dependency.vpc.outputs.name
  name_prefix = "backend-db-57"

  ingress = [
    {
      Description = "Allow all traffic from cluster"
      from_port   = 6379
      to_port     = 6379
      protocol    = "TCP"
      cidr_blocks = [dependency.vpc.outputs.cidr_block]
    }
  ]

  egress = [
    {
      Description = "Allow ALL Egress Traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  # Tags are required (when possible)
  tags = local.tags
}