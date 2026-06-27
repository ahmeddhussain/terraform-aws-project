locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "3-tier-web-app"
  }

  frontend_alb_name = "${var.alb_name}-${var.environment}"
  frontend_tg_name  = "frontend-tg-${var.environment}"
  backend_alb_name  = "backend-alb-${var.environment}"
  backend_tg_name   = "backend-tg-${var.environment}"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

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

resource "aws_launch_template" "frontend" {
  name_prefix   = "frontend-lt-${var.environment}"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_pair_name

  vpc_security_group_ids = [
    var.frontend_sg_id
  ]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install -y nginx1
              systemctl enable nginx
              systemctl start nginx
              cat > /usr/share/nginx/html/index.html << 'EOT'
              <html><body><h1>Frontend Web Tier</h1>
              <p>Environment: ${var.environment}</p>
              </body></html>
              EOT
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "frontend-instance-${var.environment}"
      Environment = var.environment
    }
  }
}

resource "aws_autoscaling_group" "frontend" {
  name = "frontend-asg-${var.environment}"

  min_size         = var.min_size
  desired_capacity = var.desired_capacity
  max_size         = var.max_size

  vpc_zone_identifier = var.public_subnet_ids
  target_group_arns   = [aws_lb_target_group.frontend.arn]

  launch_template {
    id      = aws_launch_template.frontend.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "frontend-asg-${var.environment}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }
}

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
    path = "/"
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

resource "aws_launch_template" "backend" {
  name_prefix   = "backend-lt-${var.environment}"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.backend_instance_type
  key_name      = var.key_pair_name

  vpc_security_group_ids = [
    var.backend_sg_id
  ]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y python3
              systemctl enable --now amazon-ssm-agent
              nohup python3 -m http.server 8080 &
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "backend-instance-${var.environment}"
      Environment = var.environment
    }
  }
}

resource "aws_autoscaling_group" "backend" {
  name = "backend-asg-${var.environment}"

  min_size         = var.min_size
  desired_capacity = var.desired_capacity
  max_size         = var.max_size

  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [aws_lb_target_group.backend.arn]

  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "backend-asg-${var.environment}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }
}
