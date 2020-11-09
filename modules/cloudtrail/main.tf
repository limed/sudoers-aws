locals {
  bucket_name = "${var.cloudtrail_bucket}-${data.aws_caller_identity.current.account_id}"
  account_id  = data.aws_caller_identity.current.account_id
}

resource "aws_cloudtrail" "cloudtrail" {
  name                          = var.trail_name
  s3_bucket_name                = local.bucket_name
  is_multi_region_trail         = true
  include_global_service_events = true
  enable_logging                = true
  enable_log_file_validation    = true
}

data "aws_iam_policy_document" "cloudtrail" {
  statement {
    sid       = "AWSCloudTrailAclCheck"
    effect    = "Allow"
    actions   = ["s3:GetBucketAcl"]
    resources = ["arn:aws:s3:::${local.bucket_name}"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }

  statement {
    sid       = "AWSCloudTrailWrite"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${local.bucket_name}/AWSLogs/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_s3_bucket" "cloudtrail-bucket" {
  bucket = local.bucket_name
  acl    = "private"
  policy = data.aws_iam_policy_document.cloudtrail.json
}
