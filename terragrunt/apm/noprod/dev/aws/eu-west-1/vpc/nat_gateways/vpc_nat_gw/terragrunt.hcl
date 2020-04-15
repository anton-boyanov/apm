terraform {
  source = "${get_env("TG_ROOT_DIR", "/terragrunt")}/modules/aws//nat_gateway"
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
      Description = "VPC NAT Gateway",
    }
  )

}

dependencies {
  paths = ["../../vpcs/vpc", "../../subnets/vpc_subnets", "../../elastic_ips/vpc_nat_eip"]
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
    public_ids = ["fake-subnet-1", "fake-subnet-2", "fake-subnet-3"]
  }
}

dependency "vpc_nat_eip" {
  config_path = "../../elastic_ips/vpc_nat_eip"
  mock_outputs = {
    id = "fake-igw-id"
  }
}

inputs = {
  vpc_id        = dependency.vpc.outputs.id
  vpc_name      = dependency.vpc.outputs.name
  allocation_id = dependency.vpc_nat_eip.outputs.id
  subnet_id     = dependency.vpc_subnets.outputs.public_ids[0]

  # Tags are required (when possible)
  tags = local.tags
}