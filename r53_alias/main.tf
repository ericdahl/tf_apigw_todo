resource "aws_acm_certificate" "default" {
  domain_name       = var.domain_name
  validation_method = "DNS"
}

resource "aws_route53_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.default.domain_validation_options : dvo.domain_name => {
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
  zone_id         = var.zone_id
}

resource "aws_acm_certificate_validation" "default" {
  certificate_arn         = aws_acm_certificate.default.arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validation : record.fqdn]
}

resource "aws_apigatewayv2_domain_name" "api" {
  domain_name = var.domain_name
  domain_name_configuration {
    certificate_arn = aws_acm_certificate.default.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }

  depends_on = [aws_acm_certificate_validation.default]
}

resource "aws_route53_record" "default" {
  name    = aws_apigatewayv2_domain_name.api.domain_name
  type    = "A"
  zone_id = var.zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.api.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.api.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}


resource "aws_apigatewayv2_api_mapping" "api" {
  api_id      = var.api_id
  domain_name = aws_apigatewayv2_domain_name.api.domain_name
  stage       = var.api_stage_id
}