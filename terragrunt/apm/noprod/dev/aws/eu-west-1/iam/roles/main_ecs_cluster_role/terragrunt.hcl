terraform {
  source = "${get_env("TG_ROOT_DIR", "/terragrunt")}/modules/aws//iam_role"
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

  # Tags are not applicable here
}

dependencies {
  paths = [
    "../../../ecs/clusters/main_ecs_cluster",
  ]
}

dependency "main_ecs_cluster" {
  config_path = "../../../ecs/clusters/main_ecs_cluster"
  mock_outputs = {
    name = "fake-ecs-cluster-name"
  }
}

inputs = {
  name_prefix = "${dependency.main_ecs_cluster.outputs.name}-ecs-cluster"
  path        = "/"

  iam_istance_profile = true

  assume_role_policy = [
    {
      actions = [
        "sts:AssumeRole"
      ]

      principals = {
        type        = "Service",
        identifiers = ["ec2.amazonaws.com"]
      }
    }
  ]

  role_policy_document = [
    {
      actions = [
        "ecs:Submit*",
        "ecs:StartTelemetrySession",
        "ecs:RegisterContainerInstance",
        "ecs:PutAccountSettingDefault",
        "ecs:PutAccountSetting",
        "ecs:Poll",
        "ecs:ListAccountSettings",
        "ecs:DiscoverPollEndpoint",
        "ecs:DeregisterContainerInstance",
        "ecs:CreateCluster",
        "logs:PutLogEvents",
        "logs:CreateLogStream"
      ]
      resources = [
        "*"
      ]
    },
    {
      actions = [
        "iam:PassRole"
      ]

      resources = [
        "arn:aws:iam::${local.common_vars.account_id}:role/${local.common_vars.environment}-${local.common_vars.region_country_code}_task-*"
      ]
    }
  ]

  # Tags are not applicable here
}