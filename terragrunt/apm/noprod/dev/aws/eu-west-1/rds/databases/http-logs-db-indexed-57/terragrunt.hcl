terraform {
  source = "${get_env("TG_ROOT_DIR", "/terragrunt")}/modules/aws//rds_cluster"
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
      Description = "http-logs-db-indexed-57 RDS Cluster",
    }
  )
}

dependencies {
  paths = [
    "../../../vpc/vpcs/vpc",
    "../../../vpc/subnets/vpc_subnets",
    "../../subnet_groups",
    "../../../vpc/security_groups/http_logs_db_indexed_57_sg"
  ]
}

dependency "vpc" {
  config_path = "../../../vpc/vpcs/vpc"
  mock_outputs = {
    id = "fake-vpc_id"
  }
}

dependency "vpc_subnets" {
  config_path = "../../../vpc/subnets/vpc_subnets"
  mock_outputs = {
    private_ids = ["fake-subnet-1", "fake-subnet-2", "fake-subnet-3"]
  }
}

dependency "subnet_group" {
  config_path = "../../subnet_groups"
  mock_outputs = {
    subnet_group_name = "fake-subnet_group_name"
  }
}

dependency "http_logs_db_indexed_57_sg" {
  config_path = "../../../vpc/security_groups/http_logs_db_indexed_57_sg"
  mock_outputs = {
    id = "fake-sg_id"
  }
}

inputs = {
  identifier      = "http-logs-db-indexed-57"
  engine          = "aurora-mysql"
  engine_version  = "5.7.12"
  master_username = "master"
  environment     = local.common_vars.environment
  encrypted       = true
  # SET skip_final_snapshot to TRUE IN FINAL VERSION !!!
  skip_final_snapshot = true
  deletion_protection     = false
  apply_immediately       = false
  vpc_security_group_ids  = [dependency.http_logs_db_indexed_57_sg.outputs.id]
  db_subnet_group_name    = dependency.subnet_group.outputs.subnet_group_name
  backup_retention_period = local.common_vars.backup_retention_period.http-logs-db-indexed-57
  # SET prevent_destroy to TRUE IN FINAL VERSION !!!
  prevent_destroy         = false
  num_instances           = local.common_vars.num_instances.http-logs-db-indexed-57
  instance_type           = local.common_vars.instance_type.http-logs-db-indexed-57
  rds_monitoring_role_arn = "arn:aws:iam::${local.common_vars.account_id}:role/rds-monitoring-role"
  monitoring_interval     = local.common_vars.monitoring_interval.http-logs-db-indexed-57

  # Tags are required (when possible)
  tags = local.tags
}