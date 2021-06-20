variable "name" {
  default = "tf_apigw_todo"
}

variable "admin_cidr" {
}

variable "enable_dns_alias" {
  default = false
}

variable "dns_alias_r53_zone_id" {
  default = ""
}

variable "api_r53_dns_name" {
  default = ""
}

variable "www_r53_dns_name" {
  default = ""
}

