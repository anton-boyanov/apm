variable "vpc_name" {
  type    = string
  default = null
}

variable "name_prefix" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}