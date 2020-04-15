variable "domain_name" {
  type = string
}

variable "subject_alternative_names" {
  type    = list(string)
  default = []
}

variable "zone_id" {
  type = string
}

variable "create_dns_records" {
  type = bool
  default = false
}

variable "automatic_cert_validation" {
  type = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}