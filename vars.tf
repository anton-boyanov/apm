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
//
//variable "tokenization_backend" {
//  description = "Can be 'dummy', 's3', 'azure', or 'aws-embedded'"
//  default     = "aws-embedded"
//}
//
//variable "use_spy_service" {
//  default     = true
//  description = "If 'true' will include spy service and axis requests will go thru spy axis proxy"
//}
//
//variable "pen_testing" {
//  default = false
//}
//
//variable "enhanced_rds_monitoring_interval" {
//  default     = "0"
//  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60."
//}
//
//variable "enable_swagger" {
//  default = false
//}
variable "enough_instances_per_cluster" {}
variable "cloud_watch_retention_in_days" {}
variable "key_name" {}