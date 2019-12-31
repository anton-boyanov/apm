variable "environment" {
  description = "Deployment"
}
variable "application_name" {
  description = "Name of application"
}

variable "docker_tag" {
  description = "Docker tag of image"
}

variable "create" {
  default     = true
  description = "create all resources. Initially we will just make it scale to 0 tasks"
}

variable "tasks_per_service" {
  description = "Number of tasks"
}

variable "apm_ecr_url" {}
variable "environment_variables" {}
variable "service_name" {}
//variable "max_availability_zones" {}
variable "tags" {}
variable "alb_security_group" {}
//variable "app_subnets_ids_sorted_by_az_name" {}
//variable "dmz_subnets_ids_sorted_by_az_name" {}
variable "tag_names" {}
variable "merged_cluster_tags" {}
variable "domain" {}
//variable "certificate" {}
variable "container_port" {}
variable "container_protocol" {}
variable "alb_port" {}
variable "alb_protocol" {}
variable "internal" {}
variable "subnets" {}
variable "target_group_prefix" { /* prefix can only be max 6 characters */}
variable "vpc_id" {}
variable "aws_region_name" {}
variable "task_role_arn" {}
variable "ecs_service_role" {}
variable "ecs_cluster_id" {}
variable "cloud_watch_retention_in_days" {}
#---------------------------------------------autoscaling

variable "max_capacity" {}
variable "min_capacity" {}
variable "scale_up_cooldown" {}
variable "scale_up_adjustment" {}
variable "scale_down_cooldown" {}
variable "scale_down_adjustment" {}