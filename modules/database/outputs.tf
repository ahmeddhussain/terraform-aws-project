output "db_instance_endpoint" {
  description = "RDS instance endpoint."
  value       = aws_db_instance.app.endpoint
}

output "db_instance_identifier" {
  description = "RDS instance identifier."
  value       = aws_db_instance.app.id
}
