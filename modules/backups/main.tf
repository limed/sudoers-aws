provider "aws" {
  profile = "${var.aws_profile}"
  region  = "${var.aws_region}"
}

resource aws_s3_bucket "backup-bucket" {
  bucket  = "${var.backup-bucket}"
  acl     = "private"
}

resource aws_iam_user "backup-user" {
  path  = "/sudoers/backups/"
  name  = "${var.backup-user}"
}

