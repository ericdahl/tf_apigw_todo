resource "aws_s3_bucket" "www" {
  bucket = "tf-apigw-dynamo"

  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "www" {
  bucket = aws_s3_bucket.www.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_object" "www_html" {
  for_each = fileset("${path.module}/www/dist", "**/*.html")

  bucket = aws_s3_bucket.www.bucket
  key    = each.value
  source = "${path.module}/www/dist/${each.value}"
  etag   = filemd5("${path.module}/www/dist/${each.value}")

  content_type = "text/html"
}

resource "aws_s3_bucket_object" "www_js" {
  for_each = fileset("${path.module}/www/dist", "**/*.js")

  bucket = aws_s3_bucket.www.bucket
  key    = each.value
  source = "${path.module}/www/dist/${each.value}"
  etag   = filemd5("${path.module}/www/dist/${each.value}")

  content_type = "application/json"
}

resource "aws_s3_bucket_object" "www_css" {
  for_each = fileset("${path.module}/www/dist", "**/*.css")

  bucket = aws_s3_bucket.www.bucket
  key    = each.value
  source = "${path.module}/www/dist/${each.value}"
  etag   = filemd5("${path.module}/www/dist/${each.value}")

  content_type = "text/css"
}

resource "aws_s3_bucket_policy" "www_cloudfront" {
  bucket = aws_s3_bucket.www.bucket
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "CloudFrontAccessToReadObjects",
            "Effect": "Allow",
            "Principal": {
		        "AWS": "${aws_cloudfront_origin_access_identity.www.iam_arn}"
		    },
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.www.bucket}/*"
            ]
        }
    ]
}
EOF
}