remote_state {
  backend = "s3"

  config = {
    encrypt = true
    bucket = "apm-terraform-state"
    key = substr("${get_terragrunt_dir()}/terraform.tfstate", 12, 0)
    region = "eu-west-1"
    dynamodb_table = "apm-terraform-lock"

    s3_bucket_tags = {
      owner = "${get_terragrunt_dir()}"
      name = "Terraform state storage"
      project = "ElavonAPM"
    }
    dynamodb_table_tags = {
      owner = "${get_terragrunt_dir()}"
      name = "Terraform lock table"
      project = "ElavonAPM"
    }
  }
}

generate "custom" {
  path      = "custom.tf"
  if_exists = "overwrite"
  contents  = <<EOF
    terraform {
      backend "s3" {}
    }

    provider "aws" {
      region = "eu-west-1"
//      assume_role {
//        role_arn = "arn:aws:iam::999999999999:role/EndavaDevops"
//      }
    }

EOF
}
