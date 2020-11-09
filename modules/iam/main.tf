locals {
  account_id = data.aws_caller_identity.current.account_id
}

module "roles" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-roles"

  trusted_role_arns = [
    "arn:aws:iam::${local.account_id}:root",
  ]

  create_admin_role     = true
  create_poweruser_role = true

  create_readonly_role       = true
  readonly_role_requires_mfa = true

  admin_role_path     = "/${var.path_prefix}/"
  poweruser_role_path = "/${var.path_prefix}/"
  readonly_role_path  = "/${var.path_prefix}/"
}

module "admin_group" {
  source       = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"
  create_group = length(var.admin_users) > 0 ? true : false
  name         = "admin"
  group_users  = var.admin_users

  custom_group_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]
}

module "superuser_group" {
  source = "terraform-aws-modules/iam/aws//modules/iam-group-with-assumable-roles-policy"

  name        = "superusers"
  group_users = var.superusers
  assumable_roles = [
    module.roles.admin_iam_role_arn,
    module.roles.poweruser_iam_role_arn,
    module.roles.readonly_iam_role_arn,
  ]

}

module "user_group" {
  source = "terraform-aws-modules/iam/aws//modules/iam-group-with-assumable-roles-policy"

  name        = "users"
  group_users = var.users
  assumable_roles = [
    module.roles.admin_iam_role_arn,
    module.roles.poweruser_iam_role_arn,
    module.roles.readonly_iam_role_arn,
  ]
}

module "superuser_group_policies" {
  source = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"

  name                              = module.superuser_group.group_name
  create_group                      = false
  attach_iam_self_management_policy = true
}

module "user_group_policies" {
  source = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"

  name                              = module.user_group.group_name
  create_group                      = false
  attach_iam_self_management_policy = true
}
