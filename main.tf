module "accounts" {
  source      = "modules/accounts"
  aws_profile = "${var.aws_profile}"
  aws_region  = "${var.aws_region}"
  admins      = "${var.admins}"
}
