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
              systemctl restart nginx

              cat > /usr/share/nginx/html/index.html << 'EOT'
              <html>
              <head>
                <meta charset="utf-8" />
                <title>Frontend Web Tier</title>
              </head>
              <body>
                <h1>Frontend Web Tier</h1>
                <p>Environment: ${var.environment}</p>
                <button id="call-backend">Call Backend API</button>
                <pre id="backend-response"></pre>
                <script>
                  document.getElementById('call-backend').addEventListener('click', async () => {
                    const resp = await fetch('/api');
                    const data = await resp.json();
                    document.getElementById('backend-response').textContent = data.message;
                  });
                </script>
              </body>
              </html>
              EOT

              cat > /etc/nginx/conf.d/backend-proxy.conf << 'EOT'
              server {
                listen 80;

                location / {
                  root /usr/share/nginx/html;
                  index index.html;
                }

                location /api {
                  proxy_pass http://${aws_lb.backend.dns_name}:8080;
                  proxy_set_header Host $host;
                  proxy_set_header X-Real-IP $remote_addr;
                  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                  proxy_set_header X-Forwarded-Proto $scheme;
                }
              }
              EOT

              systemctl reload nginx
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
