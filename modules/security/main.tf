resource "aws_security_group" "frontend_alb_sg" {
  name   = "frontend-alb-sg-${var.environment}"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "frontend-alb-sg-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_security_group" "frontend_ec2_sg" {
  name   = "frontend-ec2-sg-${var.environment}"
  vpc_id = var.vpc_id

  ingress {
    description     = "Allow HTTP from the frontend ALB."
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_alb_sg.id]
  }

  dynamic "ingress" {
    for_each = length(trimspace(var.allowed_ssh_cidr)) > 0 ? [1] : []
    content {
      description = "Allow SSH from a restricted CIDR block."
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.allowed_ssh_cidr]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "frontend-ec2-sg-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_security_group" "backend_alb_sg" {
  name   = "backend-alb-sg-${var.environment}"
  vpc_id = var.vpc_id

  ingress {
    description     = "Allow HTTP from frontend instances."
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "backend-alb-sg-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_security_group" "backend_ec2_sg" {
  name   = "backend-ec2-sg-${var.environment}"
  vpc_id = var.vpc_id

  ingress {
    description     = "Allow traffic from the backend ALB."
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_alb_sg.id]
  }

  dynamic "ingress" {
    for_each = length(trimspace(var.allowed_ssh_cidr)) > 0 ? [1] : []
    content {
      description = "Allow SSH from a restricted CIDR block."
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.allowed_ssh_cidr]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "backend-ec2-sg-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_security_group" "db_sg" {
  name   = "db-sg-${var.environment}"
  vpc_id = var.vpc_id

  ingress {
    description     = "Allow MySQL from the backend EC2 instances."
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "db-sg-${var.environment}"
    Environment = var.environment
  }
}