output "lb_dns_name" {
  value = aws_lb.elk.dns_name
}
output "lb_zone_id" {
  value = aws_lb.elk.zone_id
}
