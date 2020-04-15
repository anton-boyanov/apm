variable "certificate_arn" {
  type = string
  default = ""
}

variable "validation_record_fqdns" {
  type = list(string)
  default = []
}