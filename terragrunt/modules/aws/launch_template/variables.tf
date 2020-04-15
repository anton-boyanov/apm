variable "name_prefix" {
  type    = string
  default = ""
}

variable "volume_size" {
  type    = string
  default = ""
}

variable "iam_instance_profile" {
  type    = string
  default = ""
}

variable "instance_type" {
  type    = string
  default = ""
}

variable "key_name" {
  type    = string
  default = ""
}

variable "vpc_security_group_ids" {
  type    = list(string)
  default = []
}

variable "user_data" {
  type    = string
  default = ""
}

variable "user_data_vars" {
  type    = any
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}