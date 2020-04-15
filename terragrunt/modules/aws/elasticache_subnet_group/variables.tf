variable "name" {
  type = string
  default = "default-redis-subnet-group"
}

variable "subnet_ids" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}