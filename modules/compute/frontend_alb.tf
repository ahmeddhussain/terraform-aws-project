resource "aws_lb" "frontend" {
  name               = local.frontend_alb_name
  load_balancer_type = var.alb_type
  subnets            = var.public_subnet_ids
  security_groups    = [var.alb_sg_id]

  tags = merge(local.common_tags, {
    Name = local.frontend_alb_name
  })
}

resource "aws_lb_target_group" "frontend" {
  name     = local.frontend_tg_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = "/"
  }

  tags = merge(local.common_tags, {
    Name = local.frontend_tg_name
  })
}

resource "aws_lb_listener" "frontend" {
  load_balancer_arn = aws_lb.frontend.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}
