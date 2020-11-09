
locals {
  iam_username       = var.iam_username == "" ? var.bucket_name : var.iam_username
  backup_policy_name = "bucket-write"

  tags = {
    "Region"    = var.region
    "Terraform" = "true"
  }
}

resource "aws_s3_bucket" "this" {
  count  = var.enabled ? 1 : 0
  bucket = var.bucket_name

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rule

    content {
      id                                     = lookup(lifecycle_rule.value, "id", null)
      prefix                                 = lookup(lifecycle_rule.value, "prefix", null)
      tags                                   = lookup(lifecycle_rule.value, "tags", null)
      abort_incomplete_multipart_upload_days = lookup(lifecycle_rule.value, "abort_incomplete_multipart_upload_days", null)
      enabled                                = lifecycle_rule.value.enabled

      # Max 1 block - expiration
      dynamic "expiration" {
        for_each = length(keys(lookup(lifecycle_rule.value, "expiration", {}))) == 0 ? [] : [lookup(lifecycle_rule.value, "expiration", {})]

        content {
          date                         = lookup(expiration.value, "date", null)
          days                         = lookup(expiration.value, "days", null)
          expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", null)
        }
      }

      # Several blocks - transition
      dynamic "transition" {
        for_each = lookup(lifecycle_rule.value, "transition", [])

        content {
          date          = lookup(transition.value, "date", null)
          days          = lookup(transition.value, "days", null)
          storage_class = transition.value.storage_class
        }
      }
    }
  }


  tags = merge({ "Name" = var.bucket_name }, local.tags)
}

resource "aws_iam_user" "this" {
  count = var.enabled && var.create_iam_user ? 1 : 0
  name  = local.iam_username
  tags  = merge({ "Name" = local.iam_username }, local.tags)
}

resource "aws_iam_access_key" "this" {
  count = var.enabled && var.create_iam_user && var.create_iam_key ? 1 : 0
  user  = aws_iam_user.this[0].name
}

resource "aws_iam_user_policy" "this" {
  count  = var.enabled && var.create_iam_user ? 1 : 0
  name   = local.backup_policy_name
  user   = aws_iam_user.this[0].name
  policy = data.aws_iam_policy_document.this[0].json
}
