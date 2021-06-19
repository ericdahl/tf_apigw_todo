resource "aws_s3_bucket" "www" {
  bucket = "tf-apigw-dynamo"

  force_destroy = true
}

# TODO: Split up into javascript/css/html to set Content-Type
# TODO: Set up CloudFront in front, maybe
resource "aws_s3_bucket_object" "www" {
  for_each = fileset("${path.module}/www/dist", "**")

  bucket = aws_s3_bucket.www.bucket
  key = each.value
  source = "${path.module}/www/dist/${each.value}"
  etag = filemd5("${path.module}/www/dist/${each.value}")
}