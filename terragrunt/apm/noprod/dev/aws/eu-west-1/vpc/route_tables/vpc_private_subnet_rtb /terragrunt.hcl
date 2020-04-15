terraform {
  source = "${get_env("TG_ROOT_DIR", "/terragrunt")}/modules/aws//route_table"
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
      Description = "VPC Private Subnets Route Table",
    }
  )

}

dependencies {
  paths = ["../../vpcs/vpc", "../../subnets/vpc_subnets", "../../nat_gateways/vpc_nat_gw"]
}

dependency "vpc" {
  config_path = "../../vpcs/vpc"
  mock_outputs = {
    id   = "fake-vpc-id"
    name = "fake-vpc-name"
  }
}

dependency "vpc_subnets" {
  config_path = "../../subnets/vpc_subnets"
  mock_outputs = {
    private_ids = ["fake-subnet-1", "fake-subnet-2", "fake-subnet-3"]
  }
}

dependency "vpc_nat_gw" {
  config_path = "../../nat_gateways/vpc_nat_gw"
  mock_outputs = {
    id = "fake-nat-gw-id"
  }
}

inputs = {
  vpc_id                 = dependency.vpc.outputs.id
  vpc_name               = dependency.vpc.outputs.name
  name_prefix            = "private-subnet"
  subnet_association     = true
  subnet_association_ids = dependency.vpc_subnets.outputs.private_ids
  routes = [
    {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = dependency.vpc_nat_gw.outputs.id
    }
  ]
  # Tags are required (when possible)
  tags = local.tags
}