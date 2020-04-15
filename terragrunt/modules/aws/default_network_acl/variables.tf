variable "vpc_id" {
  type    = string
  default = null
}

variable "vpc_name" {
  type    = string
  default = null
}

variable "ingress" {
  type    = any
  default = []
}

variable "egress" {
  type    = any
  default = []
}

variable "default_network_acl_id" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}