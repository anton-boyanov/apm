variable "name" {
  type    = string
  default = null
}

variable "load_balancer_type" {
  type    = string
  default = "application"
}

variable "internal" {
  type    = bool
  default = false
}

variable "security_groups" {
  type    = list(string)
  default = []
}

variable "subnets" {
  type    = list(string)
  default = null
}

variable "idle_timeout" {
  type    = number
  default = 60
}

variable "enable_cross_zone_load_balancing" {
  type    = bool
  default = false
}

variable "enable_deletion_protection" {
  type    = bool
  default = false
}

variable "enable_http2" {
  type    = bool
  default = true
}

variable "ip_address_type" {
  type    = string
  default = null
}

variable "access_logs" {
  type    = map(string)
  default = {}
}

variable "subnet_mapping" {
  type    = list(map(string))
  default = []
}

variable "load_balancer_create_timeout" {
  type    = string
  default = null
}

variable "load_balancer_update_timeout" {
  type    = string
  default = null
}

variable "load_balancer_delete_timeout" {
  type    = string
  default = null
}

variable "tcp_http_listeners" {
  type    = list(map(string))
  default = []
}

variable "https_listeners" {
  type    = list(map(string))
  default = []
}

variable "listener_ssl_policy_default" {
  type    = string
  default = null
}

variable "extra_ssl_certs" {
  type    = list(map(string))
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}