variable "key_name" {
  type    = string
  default = null
}

variable "public_key" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}