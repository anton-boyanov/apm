variable "names" {
  description = "Name of the repo"
  type        = list(string)
  default     = [
    "configuration",
    "file-storage",
    "transaction"
  ]
}
variable "application_name" {}
variable "environment" {}