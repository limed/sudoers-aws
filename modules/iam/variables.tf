variable "region" {
  default = "us-west-2"
}

variable "path_prefix" {
  default = "sudoers"
}

variable "admin_users" {
  type    = list(string)
  default = []
}

variable "superusers" {
  type    = list(string)
  default = []
}

variable "users" {
  type    = list(string)
  default = []
}
