resource "aws_db_subnet_group" "rds" {
  name       = "rds-subnet-group-${var.environment}"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "rds-subnet-group-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_db_parameter_group" "rds" {
  name        = "rds-parameter-group-${var.environment}"
  family      = "mysql8.0"
  description = "Custom RDS parameter group for ${var.environment}."

  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  parameter {
    name  = "log_output"
    value = "FILE"
  }
}

resource "aws_db_instance" "app" {
  identifier              = "app-db-${var.environment}"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  storage_type            = "gp3"
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.rds.name
  vpc_security_group_ids  = [var.db_sg_id]
  skip_final_snapshot     = true
  publicly_accessible     = false
  multi_az                = false
  backup_retention_period = 7
  apply_immediately       = true
  parameter_group_name    = aws_db_parameter_group.rds.name

  tags = {
    Name        = "app-db-${var.environment}"
    Environment = var.environment
  }
}
