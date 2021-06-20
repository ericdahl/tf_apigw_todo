resource "aws_acm_certificate" "www" {
  domain_name       = var.www_r53_dns_name
  validation_method = "DNS"
}

resource "aws_route53_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.www.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.dns_alias_r53_zone_id
}

resource "aws_acm_certificate_validation" "default" {
  certificate_arn         = aws_acm_certificate.www.arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validation : record.fqdn]
}

resource "aws_cloudfront_origin_access_identity" "www" {}

resource "aws_route53_record" "www" {
  zone_id = var.dns_alias_r53_zone_id
  name    = "www"
  type    = "A"

  alias {
    zone_id                = aws_cloudfront_distribution.www.hosted_zone_id
    name                   = aws_cloudfront_distribution.www.domain_name
    evaluate_target_health = false
  }
}


resource "aws_cloudfront_distribution" "www" {
  origin {
    origin_id   = aws_s3_bucket.www.bucket
    domain_name = aws_s3_bucket.www.bucket_regional_domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.www.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = [var.www_r53_dns_name]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.www.bucket

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    compress = true

    viewer_protocol_policy = "https-only"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100" # US, Canada and Europe

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = var.name
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.www.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }
}