variable "cidr_block" {
  type    = string
  default = "0.0.0.0/0"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "vpc-flow-logs_bucket_arn" {
  type    = string
  default = ""
}