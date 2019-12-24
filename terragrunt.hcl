remote_state {
  backend = "s3"

  config = {
    encrypt = true
    bucket = "terragrunt-eu-west-1-apm-nonprod-${path_relative_to_include()}"
    key = "${path_relative_to_include()}/terraform.tfstate"
    region = "eu-west-1"
    dynamodb_table = "terragrunt-apm-locks-${path_relative_to_include()}"
    s3_bucket_tags = {
      owner = "terragrunt integration ${path_relative_to_include()}"
      name = "Terraform state storage"
      project = "ElavonAPM"
    }
    dynamodb_table_tags = {
      owner = "terragrunt integration ${path_relative_to_include()}"
      name = "Terraform lock table"
      project = "ElavonAPM"
    }
  }
}