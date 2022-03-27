resource aws_s3_bucket common {
  bucket = "${var.account.env}-common"
  tags   = merge({
    Name = "${var.account.env}-vpc"
  }, var.tags)
}

resource aws_s3_bucket_acl acl {
  bucket = aws_s3_bucket.common.bucket
  acl    = "private"
}
