resource "aws_route53_record" "monitoring" {
  zone_id = var.zone_id
  name    = var.monitoring
  type    = "A"
  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "apm" {
  zone_id = var.zone_id
  name    = var.apm
  type    = "A"
  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
