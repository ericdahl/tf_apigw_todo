output "dns_alias_url" {
  value = var.enable_dns_alias ? module.r53_alias[0].url : null
}