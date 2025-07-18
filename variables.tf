variable "vpc_id" {
  description = "ID of the existing VPC"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate covering monitoring and apm domains"
  type        = string
}

variable "domain_name" {
  description = "Root domain (e.g. example.com)"
  type        = string
}

variable "monitoring_subdomain" {
  description = "Subdomain for Kibana (e.g. analytics)"
  type        = string
}

variable "apm_subdomain" {
  description = "Subdomain for APM (e.g. apm)"
  type        = string
}

variable "search_subdomain" {
  description = "Subdomain for Elastic Search (e.g. search)"
  type        = string
}

variable "discord_webhook_url" {
  description = "Discord webhook URL for ELK notifications"
  type        = string
  sensitive   = true
}
