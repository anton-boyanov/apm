# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  #source = "git::ssh://git@git.servers.global.prv/ag/control-app-apm.git"
  # ! Note the double slash(//) is required for local paths in order for relative paths to work properly
   source = "../"
  # You can reffer to a specific tag(git tag) for versioning, using the 'ref' param in the URL, like that:
  # ssh://git@git.servers.global.prv/ag/control-app-apm.git//?ref=v1.0.0
}

//dependencies {
//  paths = ["../static"]
//}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
# ---------------------------------------------------------------------------------------------------------------------

inputs = {
  awsRegion = "eu-west-1"
  application_name = "apm"
  environment = "qa"
  max_availability_zones = 2
  performance_level = "low"
  key_name = "ElavonApmGateway"
  cloud_watch_retention_in_days = 1
}