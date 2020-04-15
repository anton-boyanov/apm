variable "name" {
  type    = string
  default = ""
}

variable "settings" {
  type    = any
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}