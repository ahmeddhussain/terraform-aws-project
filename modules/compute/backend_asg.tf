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
yum install -y python3 python3-pip mysql
pip3 install flask pymysql
systemctl enable --now amazon-ssm-agent

mkdir -p /opt/backend
cat > /opt/backend/app.py <<'EOT'
import os
import pymysql
from flask import Flask, jsonify

app = Flask(__name__)

DB_HOST = os.environ.get('DB_HOST')
DB_USER = os.environ.get('DB_USER')
DB_PASSWORD = os.environ.get('DB_PASSWORD')
DB_NAME = 'appdb'


def ensure_database_exists():
  # Connect without selecting a database to create it if missing
  conn = pymysql.connect(host=DB_HOST, user=DB_USER, password=DB_PASSWORD, cursorclass=pymysql.cursors.DictCursor)
  try:
    with conn.cursor() as cursor:
      cursor.execute(f"CREATE DATABASE IF NOT EXISTS `{DB_NAME}` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci")
    conn.commit()
  finally:
    conn.close()


@app.route('/api')
def api():
  ensure_database_exists()

  conn = pymysql.connect(
    host=DB_HOST,
    user=DB_USER,
    password=DB_PASSWORD,
    database=DB_NAME,
    cursorclass=pymysql.cursors.DictCursor,
  )
  try:
    with conn.cursor() as cursor:
      cursor.execute("CREATE TABLE IF NOT EXISTS messages (id INT AUTO_INCREMENT PRIMARY KEY, message VARCHAR(255))")
      cursor.execute("SELECT COUNT(*) AS cnt FROM messages")
      row = cursor.fetchone()
      cnt = row['cnt'] if row else 0
      if cnt == 0:
        cursor.execute("INSERT INTO messages (message) VALUES (%s)", ('Hello From Ahmed, Thank You For Using My Project',))
        conn.commit()
      cursor.execute("SELECT message FROM messages ORDER BY id DESC LIMIT 1")
      result = cursor.fetchone()
      message = result['message'] if result else 'No message found'
  finally:
    conn.close()

  return jsonify({
    'message': message,
    'environment': '${var.environment}'
  })


@app.route('/health')
def health():
  return jsonify({'status': 'ok'})


if __name__ == '__main__':
  app.run(host='0.0.0.0', port=8080)
EOT

cat > /etc/systemd/system/backend-api.service <<'EOT'
[Unit]
Description=Simple Flask Backend API
After=network.target

[Service]
ExecStart=/usr/bin/python3 /opt/backend/app.py
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOT

cat > /etc/systemd/system/backend-api.service <<'EOT'
[Unit]
Description=Simple Flask Backend API
After=network.target

[Service]
Environment=DB_HOST=${var.db_endpoint}
Environment=DB_USER=${var.db_username}
Environment=DB_PASSWORD=${var.db_password}
ExecStart=/usr/bin/python3 /opt/backend/app.py
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOT

systemctl daemon-reload
systemctl enable --now backend-api.service
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
