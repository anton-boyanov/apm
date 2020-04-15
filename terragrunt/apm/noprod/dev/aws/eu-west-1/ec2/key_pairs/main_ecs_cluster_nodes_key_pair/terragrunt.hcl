terraform {
  source = "${get_env("TG_ROOT_DIR", "/terragrunt")}/modules/aws//key_pair"
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
      Description = "Main ECS Cluster Key Pair",
    }
  )
}

dependencies {
  paths = [
    "../../../ecs/clusters/main_ecs_cluster"
  ]
}

dependency "main_ecs_cluster" {
  config_path = "../../../ecs/clusters/main_ecs_cluster"
  mock_outputs = {
    name = "fake-ecs-cluster-name"
  }
}

inputs = {
  key_name   = "${dependency.main_ecs_cluster.outputs.name}-ecs-cluster-key-pair"
  public_key = local.common_vars.ecs_main_cluster_key_pair_public_key
  # Tags are required (when possible)
  tags = local.tags
}