resource "aws_s3_bucket" "www" {
  bucket = "tf-apigw-dynamo"

  force_destroy = true
}

# TODO: Split up into javascript/css/html to set Content-Type
# TODO: Set up CloudFront in front, maybe
resource "aws_s3_bucket_object" "www_html" {
  for_each = fileset("${path.module}/www/dist", "**/*.html")

  bucket = aws_s3_bucket.www.bucket
  key    = each.value
  source = "${path.module}/www/dist/${each.value}"
  etag   = filemd5("${path.module}/www/dist/${each.value}")

  content_type = "text/html"

  acl = "public-read" # TODO: fixme
}

resource "aws_s3_bucket_object" "www_js" {
  for_each = fileset("${path.module}/www/dist", "**/*.js")

  bucket = aws_s3_bucket.www.bucket
  key    = each.value
  source = "${path.module}/www/dist/${each.value}"
  etag   = filemd5("${path.module}/www/dist/${each.value}")

  content_type = "application/json"

  acl = "public-read" # TODO: fixme
}

resource "aws_s3_bucket_object" "www_css" {
  for_each = fileset("${path.module}/www/dist", "**/*.css")

  bucket = aws_s3_bucket.www.bucket
  key    = each.value
  source = "${path.module}/www/dist/${each.value}"
  etag   = filemd5("${path.module}/www/dist/${each.value}")

  content_type = "text/css"

  acl = "public-read" # TODO: fixme
}