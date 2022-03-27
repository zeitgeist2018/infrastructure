resource aws_s3_bucket common {
  bucket = "${var.account.env}---common"
  tags   = merge({
    Name = "${var.account.env}-vpc"
  }, var.tags)
}

resource aws_s3_bucket_acl acl {
  bucket = aws_s3_bucket.common.bucket
  acl    = "private"
}

resource aws_s3_bucket_policy assets {
  bucket = aws_s3_bucket.common.id
  policy = jsonencode({
    Version   = "2012-10-17"
    Id        = "ec2",
    Statement = [
      {
        Effect    = "Allow"
        Principal = ["*"]
        Action : [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListObjects",
          "s3:PutObject"
        ],
        Resource : [
          aws_s3_bucket.common.arn,
          "${aws_s3_bucket.common.arn}/*"
        ]
      }
    ]
  })
}
