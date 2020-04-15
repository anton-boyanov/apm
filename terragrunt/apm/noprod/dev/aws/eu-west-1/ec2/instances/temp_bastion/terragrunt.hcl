terraform {
  source = "${get_env("TG_ROOT_DIR", "/terragrunt")}/modules/aws//ec2_instance"
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
      Description = "Temp EC2 Bastion Host"
    }
  )

}

dependencies {
  paths = [
    "../../../vpc/security_groups/temp_bastion_sg",
    "../../../vpc/subnets/vpc_subnets",
    "../../../ec2/key_pairs/main_ecs_cluster_nodes_key_pair",
  ]
}

dependency "main_ecs_cluster_nodes_key_pair" {
  config_path = "../../../ec2/key_pairs/main_ecs_cluster_nodes_key_pair"
  mock_outputs = {
    name = "fake-key-pair"
  }
}

dependency "temp_bastion_sg" {
  config_path = "../../../vpc/security_groups/temp_bastion_sg"
  mock_outputs = {
    id = "fake-id"
  }
}

dependency "vpc_subnets" {
  config_path = "../../../vpc/subnets/vpc_subnets"
  mock_outputs = {
    public_ids = ["fake-subnet-1", "fake-subnet-2", "fake-subnet-3"]
  }
}

inputs = {
  name                        = "temp-bastion-host"
  instance_type               = "t2.nano"
  ami                         = "ami-03b5297d565ef30a6"
  key_name                    = dependency.main_ecs_cluster_nodes_key_pair.outputs.name
  security_groups             = [dependency.temp_bastion_sg.outputs.id]
  subnet_id                   = dependency.vpc_subnets.outputs.public_ids[0]
  associate_public_ip_address = true

  # Tags are required (when possible)
  tags = local.tags
}