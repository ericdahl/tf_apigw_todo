output "url" {
  value = "https://${aws_route53_record.default.fqdn}"
}