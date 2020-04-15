variable "vpc_id" {
  type    = string
  default = null
}

variable "vpc_name" {
  type    = string
  default = null
}

variable "subnet_association" {
  type    = bool
  default = false
}

variable "subnet_association_ids" {
  type    = list(string)
  default = []
}

variable "name_prefix" {
  type    = string
  default = null
}

variable "routes" {
  type    = list(map(string))
  default = []
}


variable "tags" {
  type    = map(string)
  default = {}
}