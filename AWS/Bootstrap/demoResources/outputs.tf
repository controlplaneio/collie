output "logging_bucket_name" {
  value = aws_s3_bucket.logging_bucket.bucket
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "replication_bucket_arn" {
  value = aws_s3_bucket.replication_bucket.arn
}

output "replication_encryption_key_arn" {
  value = aws_kms_key.replication_encryption_key.arn
}