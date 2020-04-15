variable "vpc_id" {
  type    = string
  default = null
}

variable "vpc_name" {
  type    = string
  default = null
}

variable "name_prefix" {
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

variable "tags" {
  type    = map(string)
  default = {}
}