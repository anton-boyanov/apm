variable "environment" {
  description = "Name of the environment such as 'dev', 'qa', etc"
}
variable "application_name" {
  description = "Application name"
}
variable "awsRegion" {
  description = "Region to place all resources"
}
variable "max_availability_zones" {
  description = "Maximum number of availability zones to use. Actual number depends on set up of VPC subnets and AWS region"
}
variable "performance_level" {
  description = "Level that ditates EC2 instance types, Database instance types, etc. Values of 'low' , 'medium', or 'high'"
}
variable "cloud_watch_retention_in_days" {}
variable "key_name" {}
