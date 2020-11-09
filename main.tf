provider "aws" {
  region = var.region
}

module "master-zone" {
  source      = "./modules/dns/master-zone"
  domain_name = "sudoers.cloud"
}

module "cloudtrail" {
  source = "./modules/cloudtrail"
}

module "iam_account" {
  source        = "terraform-aws-modules/iam/aws//modules/iam-account"
  version       = "~> 3"
  account_alias = "sudoers"
}

module "limed" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-user"
  name                          = "limed"
  pgp_key                       = "keybase:limed"
  create_iam_access_key         = true
  create_iam_user_login_profile = true
  password_reset_required       = false
}

module "iam" {
  source      = "./modules/iam"
  admin_users = [module.limed.this_iam_user_name]
  superusers  = [module.limed.this_iam_user_name]
}

module "hyper_backup" {
  source          = "./modules/buckets"
  bucket_name     = "synology-backup-${data.aws_caller_identity.current.account_id}"
  create_iam_user = true
  create_iam_key  = true
  iam_username    = "synology-backup"
}

# Imported
module "limed-sudoers-backupbucket" {
  source          = "./modules/buckets"
  bucket_name     = "limed-sudoers-backupbucket"
  lifecycle_rule  = local.lifecycle_rule
  create_iam_user = true
  create_iam_key  = true
  iam_username    = "sudoers-backups"
}

