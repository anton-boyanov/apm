variable "vpc_id" {
  type    = string
  default = null
}

variable "vpc_name" {
  type    = string
  default = null
}

variable "allocation_id" {
  type    = string
  default = null
}

variable "subnet_id" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}