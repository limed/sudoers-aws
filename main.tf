module "accounts" {
  source = "modules/accounts"

  aws_profile = "${var.aws_profile}"

  admins = "${var.admins}"
}
