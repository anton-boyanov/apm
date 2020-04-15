variable "type" {
  type    = string
  default = ""
}

variable "ttl" {
  type    = string
  default = ""
}

variable "name" {
  type    = string
  default = ""
}

variable "records" {
  type    = list(string)
  default = []
}

variable "set_identifier" {
  type    = string
  default = ""
}

variable "health_check_id" {
  type    = string
  default = ""
}

variable "alias" {
  type    = map
  default = {}
}

variable "multivalue_answer_routing_policy" {
  type    = bool
  default = null
}

variable "allow_overwrite" {
  type    = bool
  default = false
}

variable "zone_id" {
  type    = string
  default = ""
}