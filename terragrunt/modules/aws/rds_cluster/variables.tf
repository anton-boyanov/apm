variable "identifier" {
  type    = string
  default = ""
}

variable "environment" {
  type    = string
  default = ""
}

variable "availability_zones" {
  type    = list(string)
  default = []
}

variable "master_username" {
  type    = string
  default = "master"
}

variable "master_password" {
  type    = string
  default = "tidemaster123"
}

variable "engine" {
  type    = string
  default = "aurora"
}

variable "engine_version" {
  type    = string
  default = ""
}

variable "engine_mode" {
  description = "The database engine mode. Valid values: `parallelquery`, `provisioned`, `serverless`"
  type        = string
  default     = "provisioned"
}

variable "vpc_security_group_ids" {
  type    = list(string)
  default = []
}

variable "db_subnet_group_name" {
  type    = string
  default = ""
}

variable "skip_final_snapshot" {
  type    = bool
  default = false
}

variable "encrypted" {
  type    = string
  default = true
}

variable "backup_retention_period" {
  type    = number
  default = 7
}

variable "prevent_destroy" {
  type    = bool
  default = true
}

variable "apply_immediately" {
  type    = bool
  default = false
}

variable "rds_cluster_param_group_name" {
  type    = string
  default = ""
}

variable "scaling_configuration" {
  type = list(object({
    auto_pause               = bool
    max_capacity             = number
    min_capacity             = number
    seconds_until_auto_pause = number
  }))
  default     = []
  description = "List of nested attributes with scaling properties. Only valid when `engine_mode` is set to `serverless`"
}

variable "num_instances" {
  type    = number
  default = 1
}

variable "instance_type" {
  type    = string
  default = "db.t2.small"
}

variable "publicly_accessible" {
  type    = bool
  default = false
}

variable "deletion_protection" {
  type    = bool
  default = true
}

variable "copy_tags_to_snapshot" {
  type    = bool
  default = true
}

variable "rds_db_param_group_name" {
  type    = string
  default = ""
}

variable "rds_monitoring_role_arn" {
  type    = string
  default = ""
}

variable "monitoring_interval" {
  type    = number
  default = 60
}

variable "final_snapshot_identifier" {
  type = string
  default = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}