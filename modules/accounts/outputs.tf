output "admin_users" {
  value = "${join(",", aws_iam_access_key.admin.*.user)}"
}

output "admin_access_keys" {
  value = "${join(",", aws_iam_access_key.admin.*.id)}"
}

output "admin_secret_keys" {
  value = "${join(",", aws_iam_access_key.admin.*.secret)}"
}

output "admin_roles" {
  value = "${join(",", aws_iam_role.admin.*.arn)}"
}

output "account_id" {
  value = "${element(split(":",aws_iam_group.admins.arn), 4)}"
}

output "readonly_role" {
  value = "${join(",", aws_iam_role.readonly.*.arn)}"
}
