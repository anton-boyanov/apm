variable "domain_name" {
  type    = string
  default = ""
}

variable "elasticsearch_version" {
  type    = string
  default = "7.4"
}

variable "availability_zone_count" {
  type    = string
  default = 2
}

variable "instance_type" {
  type = string
}

variable "instance_count" {
  type = number
  default = 2
}

variable "zone_awareness_enabled" {
  type = bool
  default = true
}

variable "ebs_enabled" {
  type = bool
  default = true
}

variable "volume_size" {
  type = string
}

variable "subnet_ids" {
  type    = list(string)
  default = []
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}

variable "automated_snapshot_start_hour" {
  type = string
  default = 23
}

variable "encrypted" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
