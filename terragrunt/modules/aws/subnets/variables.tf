variable "vpc_id" {
  type    = string
  default = ""
}

variable "cidr_block" {
  type    = string
  default = ""
}

variable "private_subnets" {
  type    = list(string)
  default = []
}

variable "public_subnets" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "vpc_name" {
  type    = string
  default = ""
}