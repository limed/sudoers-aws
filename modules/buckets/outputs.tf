output "bucket_name" {
  value = element(concat(aws_s3_bucket.this.*.id, list("")), 0)
}

output "iam_user" {
  value = element(concat(aws_iam_user.this.*.name, list("")), 0)
}

output "iam_access_key" {
  value = element(concat(aws_iam_access_key.this.*.id, list("")), 0)
}

output "iam_access_secret_key" {
  value = element(concat(aws_iam_access_key.this.*.secret, list("")), 0)
}
