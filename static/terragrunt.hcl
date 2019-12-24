# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  # source = "git::ssh://git@git.servers.global.prv/ag/control-ecr-apm.git"
  source = "./"
}
# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

inputs = {
  awsRegion = "eu-west-1"
}


