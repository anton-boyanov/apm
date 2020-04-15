variable "cluster_name" {
  type    = string
  default = ""
}

variable "launch_template_id" {
  type    = string
  default = ""
}

variable "desired_capacity" {
  type    = string
  default = ""
}

variable "min_size" {
  type    = string
  default = ""
}

variable "max_size" {
  type    = string
  default = ""
}

variable "vpc_subnets" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "enable_memory_autoscaling_policy" {
  type    = bool
  default = false
}

variable "enable_cpu_autoscaling_policy" {
  type    = bool
  default = false
}

variable "enable_containers_count_autoscaling_policy" {
  type    = bool
  default = false
}