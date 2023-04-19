resource "aws_s3_bucket" "logging_bucket" {
  bucket        = "dci-logging-bucket-${var.suffix}"
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logging_bucket_encryption" {
  bucket = aws_s3_bucket.logging_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_acl" "logging_bucket_acl" {
  bucket = aws_s3_bucket.logging_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "logging_bucket_versioning" {
  bucket = aws_s3_bucket.logging_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "logging_bucket_policy" {
  bucket = aws_s3_bucket.logging_bucket.id
  policy = <<JSON
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "S3ServerAccessLogsPolicy",
            "Effect": "Allow",
            "Principal": {
                "Service": "logging.s3.amazonaws.com"
            },
            "Action": [
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::${aws_s3_bucket.logging_bucket.id}/*",
            "Condition": {
                "StringEquals": {
                    "aws:SourceAccount": "${data.aws_caller_identity.current.account_id}"
                }
            }
        }
    ]
}
JSON
}
resource "aws_s3_bucket_policy" "replication_bucket_policy" {
  bucket = aws_s3_bucket.replication_bucket.id
  policy = <<JSON
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "S3replicationPolicy",
            "Effect": "Allow",
            "Principal": {
                "Service": "s3.amazonaws.com"
            },
            "Action": [
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::${aws_s3_bucket.replication_bucket.id}/*",
            "Condition": {
                "StringEquals": {
                    "aws:SourceAccount": "${data.aws_caller_identity.current.account_id}"
                }
            }
        }
    ]
}
JSON
}

resource "aws_s3_bucket" "replication_bucket" {
  bucket        = "dci-replication-bucket-${var.suffix}"
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "replication_bucket_encryption" {
  bucket = aws_s3_bucket.replication_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_acl" "replication_bucket_acl" {
  bucket = aws_s3_bucket.replication_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "replication_bucket_versioning" {
  bucket = aws_s3_bucket.replication_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_kms_key" "replication_encryption_key" {
  policy = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "Service":"s3.amazonaws.com"
      },
      "Action": "kms:*",
      "Resource": "*",
      "Condition": {
          "StringEquals": {
            "kms:ViaService": "s3.eu-west-2.amazonaws.com",
            "kms:CallerAccount": "${data.aws_caller_identity.current.account_id}"
          }
      }
    },
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      },
      "Action": "kms:*",
      "Resource": "*"
    }
  ]
}
JSON
}