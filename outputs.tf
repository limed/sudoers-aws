output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "admin_role_arn" {
  value = module.iam.admin_role_arn
}

output "poweruser_role_arn" {
  value = module.iam.poweruser_role_arn
}

output "readonly_role_arn" {
  value = module.iam.readonly_role_arn
}

output "keybase_password_pgp_message" {
  value = base64encode(module.limed.keybase_password_pgp_message)
}

output "keybase_secret_key_pgp_message" {
  value = base64encode(module.limed.keybase_secret_key_pgp_message)
}

output "backupuser_iam_access_key" {
  value = module.limed-sudoers-backupbucket.iam_access_key
}

output "backupuser_iam_access_secret_key" {
  value = module.limed-sudoers-backupbucket.iam_access_secret_key
}

output "hyperbackup_iam_access_key" {
  value = module.hyper_backup.iam_access_key
}

output "hyperbackup_iam_access_secret_key" {
  value = module.hyper_backup.iam_access_secret_key
}

