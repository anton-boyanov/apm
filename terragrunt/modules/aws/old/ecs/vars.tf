variable "cluster_maximum_size" {}
variable "cluster_minimum_size" {}
variable "subnets" {}
variable "max_availability_zones" {}
variable "performance_level" {}
variable "subnet_ids" {}
variable "key_name" {}
variable "application_name" {}
variable "environment" {}
variable "security_group" {}
variable "iam_instance_profile" {}

variable "log_group_ssm_agent" {}
variable "log_group_ssm_agent_errors" {}
variable "log_group_messages" {}
variable "log_group_audit" {}
variable "log_group_ecs_init" {}
variable "log_group_ecs_agent" {}
variable "log_group_docker" {}
variable "log_group_dmesg" {}
variable "log_group_cluster" {}