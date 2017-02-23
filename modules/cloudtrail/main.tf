provider "aws" {
  profile = "${var.aws_profile}"
  region  = "${var.aws_region}"
}

resource "aws_cloudtrail" "cloudtrail" {
  name                          = "${var.trail_name}"
  s3_bucket_name                = "${var.cloudtrail_bucket}"
  is_multi_region_trail         = true
  include_global_service_events = true
  enable_logging                = true
  enable_log_file_validation    = true
}

resource"aws_s3_bucket" "cloudtrail-bucket" {
  bucket  = "${var.cloudtrail_bucket}"
  acl     = "private"
  policy  = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "AWSCloudTrailAclCheck",
      "Effect": "Allow",
      "Action": "s3:GetBucketAcl",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Resource": "arn:aws:s3:::${var.cloudtrail_bucket}"
    },
    {
      "Sid": "AWSCloudTrailWrite",
      "Effect": "Allow",
      "Action": "s3:PutObject",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Resource": "arn:aws:s3:::${var.cloudtrail_bucket}/AWSLogs/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    }
  ]
}
EOF
