resource "aws_lb" "backend" {
  name               = local.backend_alb_name
  internal           = true
  load_balancer_type = "application"
  subnets            = var.private_subnet_ids
  security_groups    = [var.backend_alb_sg_id]

  tags = merge(local.common_tags, {
    Name = local.backend_alb_name
  })
}

resource "aws_lb_target_group" "backend" {
  name     = local.backend_tg_name
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = "/health"
  }

  tags = merge(local.common_tags, {
    Name = local.backend_tg_name
  })
}

resource "aws_lb_listener" "backend" {
  load_balancer_arn = aws_lb.backend.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}
