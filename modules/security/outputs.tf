output "instance_sg_id" {
  value = aws_security_group.instance.id
}

output "alb_sg_id" {
  value = aws_security_group.alb.id
}
