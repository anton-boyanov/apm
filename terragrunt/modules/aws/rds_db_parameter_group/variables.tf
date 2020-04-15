variable "name" {
  type    = string
  default = ""
}

variable "cluster_family" {
  description = "The family of the DB cluster parameter group"
  type        = string
  default     = "aurora5.6"
}

variable "instance_parameters" {
  type        = list(map(string))
  default     = []
  description = "List of DB instance parameters to apply"
}

variable "tags" {
  type    = map(string)
  default = {}
}