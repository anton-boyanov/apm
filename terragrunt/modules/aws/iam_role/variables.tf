variable "name_prefix" {
  type    = string
  default = null
}

variable "path" {
  type    = string
  default = null
}

variable "role_policy_document" {
  type    = any
  default = []
}

variable "assume_role_policy" {
  type    = any
  default = []
}

variable "iam_istance_profile" {
  type    = bool
  default = false
}

