provider "aws" {
  region = var.awsRegion
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
  # required_version = "~>0.11.8"
}

locals {
  lifecyle_policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 100,
            "description": "ECR image retention policy",
            "selection": {
                "tagStatus": "untagged",
                "countType": "imageCountMoreThan",
                "countNumber": 1
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}


#APM Gateway images
module "ecr1_repository" {
  # source          = "git::ssh://git@git.servers.global.prv/ag/control-ecr-repo.git"
  source          = "./controll-ecr-repo"
  name            = "apm/apm-configuration-service"
  lifecyle_policy = local.lifecyle_policy
}

module "ecr2_repository" {
  # source          = "git::ssh://git@git.servers.global.prv/ag/control-ecr-repo.git"
  source          = "./controll-ecr-repo"
  name            = "apm/apm-encryption-service"
  lifecyle_policy = local.lifecyle_policy
}
module "ecr3_repository" {
  # source          = "git::ssh://git@git.servers.global.prv/ag/control-ecr-repo.git"
  source          = "./controll-ecr-repo"
  name            = "apm/apm-event-module-service"
  lifecyle_policy = local.lifecyle_policy
}
module "ecr4_repository" {
  # source          = "git::ssh://git@git.servers.global.prv/ag/control-ecr-repo.git"
  source          = "./controll-ecr-repo"
  name            = "apm/apm-file-downloader-service"
  lifecyle_policy = local.lifecyle_policy
}
module "ecr5_repository" {
  # source          = "git::ssh://git@git.servers.global.prv/ag/control-ecr-repo.git"
  source          = "./controll-ecr-repo"
  name            = "apm/apm-file-storage-service"
  lifecyle_policy = local.lifecyle_policy
}
module "ecr6_repository" {
  # source          = "git::ssh://git@git.servers.global.prv/ag/control-ecr-repo.git"
  source          = "./controll-ecr-repo"
  name            = "apm/apm-merchant-boarding-service"
  lifecyle_policy = local.lifecyle_policy
}
module "ecr7_repository" {
  # source          = "git::ssh://git@git.servers.global.prv/ag/control-ecr-repo.git"
  source          = "./controll-ecr-repo"
  name            = "apm/apm-merchant-config-service"
  lifecyle_policy = local.lifecyle_policy
}
module "ecr8_repository" {
  # source          = "git::ssh://git@git.servers.global.prv/ag/control-ecr-repo.git"
  source          = "./controll-ecr-repo"
  name            = "apm/apm-notification-service"
  lifecyle_policy = local.lifecyle_policy
}
module "ecr9_repository" {
  # source          = "git::ssh://git@git.servers.global.prv/ag/control-ecr-repo.git"
  source          = "./controll-ecr-repo"
  name            = "apm/apm-scheduler-service"
  lifecyle_policy = local.lifecyle_policy
}
module "ecr10_repository" {
  # source          = "git::ssh://git@git.servers.global.prv/ag/control-ecr-repo.git"
  source          = "./controll-ecr-repo"
  name            = "apm/apm-test-ppro-simulator"
  lifecyle_policy = local.lifecyle_policy
}
module "ecr11_repository" {
  # source          = "git::ssh://git@git.servers.global.prv/ag/control-ecr-repo.git"
  source          = "./controll-ecr-repo"
  name            = "apm/apm-transaction-service"
  lifecyle_policy = local.lifecyle_policy
}
module "ecr12_repository" {
  # source          = "git::ssh://git@git.servers.global.prv/ag/control-ecr-repo.git"
  source          = "./controll-ecr-repo"
  name            = "third_party/kafka"
  lifecyle_policy = local.lifecyle_policy
}
