
output "admin_users" {
  value = "${module.accounts.admin_users}"
}

output "admin_access_keys" {
  value = "${module.accounts.admin_access_keys}"
}

output "admin_secret_keys" {
  value = "${module.accounts.admin_secret_keys}"
}

output "admin_roles" {
  value = "${module.accounts.admin_roles}"
}

output "account_id" {
  value = "${module.accounts.account_id}"
}
