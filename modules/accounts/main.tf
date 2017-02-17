provider "aws" {
  profile = "${var.aws_profile}"
  region  = "${var.aws_region}"
}

resource "aws_iam_user" "admin" {
  count = "${length(split(",", var.admins))}"
  path  = "/sudoers/admins/"
  name  = name  = "${element(split(",",var.admins), count.index)}"

  force_destroy = true
}

resource "aws_iam_role_policy" "admin" {
  count = "${length(split(",",var.admins))}"
  name  = "${element(split(",",var.admins), count.index)}"

  role = "${element(split(",",var.admins), count.index)}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "*",
      "Effect": "Allow",
      "Resource": "*",
      "Sid": "admin"
    }
  ]
}
EOF
}

resource "aws_iam_role" "admin" {
  count = "${length(split(",",var.admins))}"
  path  = "/sudoers/admins/"
  name  = "${element(split(",",var.admins), count.index)}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal" : { "AWS" : "${element(aws_iam_user.admin.*.arn, count.index)}" },
      "Effect": "Allow",
      "Sid": "${element(split(",",var.admins), count.index)}"
    }
  ]
}
EOF
}
