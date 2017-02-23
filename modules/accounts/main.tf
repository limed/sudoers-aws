provider "aws" {
  profile = "${var.aws_profile}"
  region  = "${var.aws_region}"
}

resource "aws_iam_user" "admin" {
  count = "${length(split(",", var.admins))}"
  path  = "/sudoers/admins/"
  name  = "${element(split(",",var.admins), count.index)}"

  force_destroy = true
}

resource "aws_iam_role_policy" "admin" {
  name  = "admin"
  role = "${aws_iam_role.admin.id}"

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
  name  = "admin"
  path  = "/sudoers/admin/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal" : { "AWS" : [ ${join(",", formatlist("\"%s\"", aws_iam_user.admin.*.arn))} ]},
      "Effect": "Allow",
      "Sid": "admin"
    }
  ]
}
EOF
}

resource "aws_iam_role" "readonly" {
  name  = "readonly"
  path  = "/sudoers/readonly/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal" : { "AWS" : [ ${join(",", formatlist("\"%s\"", aws_iam_user.admin.*.arn))} ]},
      "Effect": "Allow",
      "Sid": "readonly"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "readonly" {
  name       = "read-only-attachments"
  roles      = ["${aws_iam_role.readonly.name}"]
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_access_key" "admin" {
  count = "${length(split(",",var.admins))}"
  user  = "${element(aws_iam_user.admin.*.name, count.index)}"
}

resource "aws_iam_group" "admins" {
  name = "Administrators"
  path = "/sudoers/admins/"
}

resource "aws_iam_policy_attachment" "admins" {
  name       = "admins"
  groups     = ["${aws_iam_group.admins.name}"]
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_group_membership" "admins" {
  name = "admins-group-membership"

  users = [
    "${aws_iam_user.admin.*.name}",
  ]

  group = "${aws_iam_group.admins.name}"
}
