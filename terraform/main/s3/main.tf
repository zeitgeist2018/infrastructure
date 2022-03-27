locals {
  bucket_name = "${var.account.env}---common"
}

resource aws_s3_bucket common {
  bucket = local.bucket_name
  tags   = merge({
    Name = "${var.account.env}-vpc"
  }, var.tags)
}

resource aws_s3_bucket_public_access_block public_access {
  bucket = aws_s3_bucket.common.bucket
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

resource aws_s3_bucket_policy policy {
  bucket = aws_s3_bucket.common.bucket
  policy = data.aws_iam_policy_document.policy.json
}

data aws_iam_policy_document policy {
  statement {
    sid    = "ec2"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [var.account.id]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::${local.bucket_name}",
      "arn:aws:s3:::${local.bucket_name}/*"
    ]
  }
}

resource aws_s3_bucket_acl acl {
  bucket = aws_s3_bucket.common.bucket
  acl    = "private"
}
