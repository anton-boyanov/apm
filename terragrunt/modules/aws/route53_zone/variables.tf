variable "zone_name" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "vpc_id" {
  type    = string
  default = null
}

variable "comment" {
  type    = string
  default = "Fix: please add a comment."
}