terraform {
  source = "${get_env("TG_ROOT_DIR", "/terragrunt")}/modules/aws//ecs_cluster_autoscaling_group"
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
      Description = "Main ECS Cluster Autoscaling Group",
    }
  )

}

dependencies {
  paths = [
    "../../launch_templates/main_ecs_cluster_launch_template",
    "../../../vpc/subnets/vpc_subnets",
    "../../../ecs/clusters/main_ecs_cluster",
  ]
}

dependency "main_ecs_cluster_launch_template" {
  config_path = "../../launch_templates/main_ecs_cluster_launch_template"
  mock_outputs = {
    id = "lt-fake"
  }
}

dependency "vpc_subnets" {
  config_path = "../../../vpc/subnets/vpc_subnets"
  mock_outputs = {
    private_ids = ["fake-subnet-1", "fake-subnet-2", "fake-subnet-3"]
  }
}

dependency "main_ecs_cluster" {
  config_path = "../../../ecs/clusters/main_ecs_cluster"
  mock_outputs = {
    name = "fake-ecs-cluster-name"
  }
}

inputs = {
  cluster_name                               = dependency.main_ecs_cluster.outputs.name
  launch_template_id                         = dependency.main_ecs_cluster_launch_template.outputs.id
  desired_capacity                           = local.common_vars.ecs_main_cluster_desired_capacity
  min_size                                   = local.common_vars.ecs_main_cluster_min_instances
  max_size                                   = local.common_vars.ecs_main_cluster_max_instances
  vpc_subnets                                = dependency.vpc_subnets.outputs.private_ids
  enable_memory_autoscaling_policy           = local.common_vars.ecs_main_cluster_enable_memory_autoscaling_policy
  enable_cpu_autoscaling_policy              = local.common_vars.ecs_main_cluster_enable_cpu_autoscaling_policy
  enable_containers_count_autoscaling_policy = local.common_vars.ecs_main_cluster_enable_containers_count_autoscaling_policy

  # Tags are required (when possible)
  tags = local.tags
}