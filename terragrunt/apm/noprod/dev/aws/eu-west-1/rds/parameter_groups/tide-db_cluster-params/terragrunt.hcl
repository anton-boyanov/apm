terraform {
  source = "${get_env("TG_ROOT_DIR", "/terragrunt")}/modules/aws//rds_cluster_parameter_group"
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
      Description = "tide-db RDS Cluster Parameter Group",
    }
  )
}

dependencies {
  paths = [
    "../../../vpc/vpcs/vpc"
  ]
}

dependency "vpc" {
  config_path = "../../../vpc/vpcs/vpc"
  mock_outputs = {
    id = "fake-vpc_id"
  }
}

inputs = {
  name           = "tide-db"
  cluster_family = "aurora5.6"

  cluster_parameters = [
    {
      name         = "character_set_client"
      value        = "utf8mb4"
      apply_method = "pending-reboot"
    },
    {
      name         = "skip-character-set-client-handshake"
      value        = "1"
      apply_method = "pending-reboot"
    },
    {
      name         = "character_set_connection"
      value        = "utf8mb4"
      apply_method = "pending-reboot"
    },
    {
      name         = "character_set_server"
      value        = "utf8mb4"
      apply_method = "pending-reboot"
    },
    {
      name         = "character_set_database"
      value        = "utf8mb4"
      apply_method = "pending-reboot"
    },
    {
      name         = "collation_server"
      value        = "utf8mb4_general_ci"
      apply_method = "pending-reboot"
    },
    {
      name         = "character_set_results"
      value        = "utf8mb4"
      apply_method = "pending-reboot"
    },
    {
      name         = "collation_connection"
      value        = "utf8mb4_general_ci"
      apply_method = "pending-reboot"
    },
    {
      name         = "binlog_format"
      value        = "ROW"
      apply_method = "pending-reboot"
    }
  ]

  # Tags are required (when possible)
  tags = local.tags
}