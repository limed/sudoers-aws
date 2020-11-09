
output "admin_role_arn" {
  value = module.roles.admin_iam_role_arn
}

output "poweruser_role_arn" {
  value = module.roles.poweruser_iam_role_arn
}

output "readonly_role_arn" {
  value = module.roles.readonly_iam_role_arn
}
