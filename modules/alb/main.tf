resource "aws_lb" "elk" {
  name               = "elk-alb"
  load_balancer_type = "application"
  subnets            = var.public_subnets
  security_groups    = [var.alb_sg_id]
}

resource "aws_lb_target_group" "kibana" {
  name_prefix = "tg-kb"
  port        = 5601
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
}

resource "aws_lb_target_group" "apm" {
  name_prefix = "tg-apm"
  port        = 8200
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
}

resource "aws_lb_target_group" "search" {
  name_prefix = "tg-es"
  port        = 9200
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
}

resource "aws_lb_target_group_attachment" "kibana" {
  target_group_arn = aws_lb_target_group.kibana.arn
  target_id        = var.instance_id
  port             = 5601
}

resource "aws_lb_target_group_attachment" "apm" {
  target_group_arn = aws_lb_target_group.apm.arn
  target_id        = var.instance_id
  port             = 8200
}

resource "aws_lb_target_group_attachment" "search" {
  target_group_arn = aws_lb_target_group.search.arn
  target_id        = var.instance_id
  port             = 9200
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.elk.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kibana.arn
  }
}

resource "aws_lb_listener_rule" "apm" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.apm.arn
  }

  condition {
    host_header { values = [var.domain_names.apm] }
  }
}

resource "aws_lb_listener_rule" "search" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 110

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.search.arn
  }

  condition {
    host_header { values = [var.domain_names.search] }
  }
}

