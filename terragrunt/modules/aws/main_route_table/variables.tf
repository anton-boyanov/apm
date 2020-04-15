variable "vpc_id" {
  type    = string
  default = null
}

variable "vpc_name" {
  type    = string
  default = null
}

variable "default_route_table_id" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}