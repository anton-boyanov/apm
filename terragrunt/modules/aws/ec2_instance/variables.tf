variable "name" {
  type = string
}

variable "ami" {
  type = string
}

variable "placement_group" {
  type    = string
  default = ""
}

variable "tenancy" {
  type    = string
  default = "default"
}

variable "ebs_optimized" {
  type    = bool
  default = false
}

variable "disable_api_termination" {
  type    = bool
  default = false
}

variable "instance_initiated_shutdown_behavior" {
  type    = string
  default = ""
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type    = string
  default = ""
}

variable "monitoring" {
  type    = bool
  default = false
}

variable "security_groups" {
  type    = list(string)
  default = null
}

variable "subnet_id" {
  type    = string
  default = ""
}

variable "subnet_ids" {
  type    = list(string)
  default = []
}

variable "associate_public_ip_address" {
  type    = bool
  default = null
}

variable "private_ip" {
  type    = string
  default = null
}

variable "source_dest_check" {
  type    = bool
  default = true
}

variable "user_data" {
  type    = string
  default = ""
}

variable "user_data_vars" {
  type    = any
  default = {}
}

variable "iam_instance_profile" {
  type    = string
  default = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "root_block_device" {
  type    = list(map(string))
  default = []
}

variable "ebs_block_device" {
  type    = list(map(string))
  default = []
}

variable "ephemeral_block_device" {
  type    = list(map(string))
  default = []
}

variable "network_interface" {
  type    = list(map(string))
  default = []
}