
variable "region" {
  default = "us-west-2"
}

variable "enabled" {
  default = true
}

variable "bucket_name" {}

variable "create_iam_user" {
  default = false
}

variable "create_iam_key" {
  default = false
}

variable "iam_username" {
  default = ""
}

variable "lifecycle_rule" {
  type    = any
  default = []
}

