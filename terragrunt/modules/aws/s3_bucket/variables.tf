variable "bucket" {
  type    = string
  default = null
}

variable "acl" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "force_destroy" {
  type    = bool
  default = false
}

variable "cors_rule" {
  type    = any # should be `map`, but it produces an error "all map elements must have the same type"
  default = {}
}

variable "bucket_policy" {
  type    = any
  default = []
}

variable "alb_access_logs_policy" {
  type    = bool
  default = false
}

variable "versioning" {
  type    = map(string)
  default = {}
}