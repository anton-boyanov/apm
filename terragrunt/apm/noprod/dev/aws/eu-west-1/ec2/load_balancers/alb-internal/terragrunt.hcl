terraform {
  source = "${get_env("TG_ROOT_DIR", "/terragrunt")}/modules/aws//load_balancer"
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
      Description = "ALB Internal",
    }
  )

}

dependencies {
  paths = [
    "../../../vpc/subnets/vpc_subnets",
    "../../../vpc/security_groups/alb_internal_sg",
    "../../../s3/alb_internal_access_logs",
    "../../../certificate_manager/certificates/internal_zone",
  ]
}

dependency "internal_zone" {
  config_path = "../../../certificate_manager/certificates/internal_zone"
  mock_outputs = {
    arn = "arn:aws:acm:fake-region:11111111:certificate/11111-11111"
  }
}

dependency "vpc_subnets" {
  config_path = "../../../vpc/subnets/vpc_subnets"
  mock_outputs = {
    private_ids = ["fake-subnet-1", "fake-subnet-2", "fake-subnet-3"]
  }
}

dependency "alb_internal_access_logs" {
  config_path = "../../../s3/alb_internal_access_logs"
  mock_outputs = {
    id  = "fake-bucket"
    arn = "arn:aws:s3:::fake-bucket"
  }
}

dependency "alb_internal_sg" {
  config_path = "../../../vpc/security_groups/alb_internal_sg"
  mock_outputs = {
    id = "fake-id"
  }
}

inputs = {

  name               = "alb-internal"
  load_balancer_type = "application"
  internal           = true
  subnets            = dependency.vpc_subnets.outputs.private_ids
  security_groups    = [dependency.alb_internal_sg.outputs.id]

  access_logs = {
    bucket  = dependency.alb_internal_access_logs.outputs.id
    enabled = true
  }

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = dependency.internal_zone.outputs.arn
      target_group_index = 0
    }
  ]

  tcp_http_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  enable_http2                     = true
  enable_cross_zone_load_balancing = false
  enable_deletion_protection       = false

  # Tags are required (when possible)
  tags = local.tags

}