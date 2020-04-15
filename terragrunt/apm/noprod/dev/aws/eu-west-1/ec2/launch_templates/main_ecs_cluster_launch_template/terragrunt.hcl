terraform {
  source = "${get_env("TG_ROOT_DIR", "/terragrunt")}/modules/aws//launch_template"
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
      Description = "Main ECS Cluster Launch Template",
    }
  )

}

dependencies {
  paths = [
    "../../../iam/roles/main_ecs_cluster_role",
    "../../../ec2/key_pairs/main_ecs_cluster_nodes_key_pair",
    "../../../vpc/security_groups/main_ecs_cluster_sg",
    "../../../ecs/clusters/main_ecs_cluster"
  ]
}

dependency "main_ecs_cluster_role" {
  config_path = "../../../iam/roles/main_ecs_cluster_role"
  mock_outputs = {
    instance_profile_name = "fake-iam-instance-profile-name"
  }
}

dependency "main_ecs_cluster_nodes_key_pair" {
  config_path = "../../../ec2/key_pairs/main_ecs_cluster_nodes_key_pair"
  mock_outputs = {
    name = "fake-key-pair"
  }
}

dependency "main_ecs_cluster_sg" {
  config_path = "../../../vpc/security_groups/main_ecs_cluster_sg"
  mock_outputs = {
    id = "fake-id"
  }
}

dependency "main_ecs_cluster" {
  config_path = "../../../ecs/clusters/main_ecs_cluster"
  mock_outputs = {
    name = "fake-ecs-cluster-name"
  }
}

inputs = {
  name_prefix            = "${dependency.main_ecs_cluster.outputs.name}-ecs-cluster"
  volume_size            = local.common_vars.ecs_main_cluster_volume_size
  iam_instance_profile   = dependency.main_ecs_cluster_role.outputs.instance_profile_name
  instance_type          = local.common_vars.ecs_main_cluster_instance_type
  key_name               = dependency.main_ecs_cluster_nodes_key_pair.outputs.name
  vpc_security_group_ids = [dependency.main_ecs_cluster_sg.outputs.id]
  user_data              = "${get_terragrunt_dir()}/user_data.sh"

  #Variables used in the user data template
  user_data_vars = {
    user_data_cluster_name = dependency.main_ecs_cluster.outputs.name
  }

  # Tags are required (when possible)
  tags = local.tags
}