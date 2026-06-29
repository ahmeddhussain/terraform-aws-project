output "vpc_id" {
  description = "VPC ID created by the network module."
  value       = module.network.vpc-cidr-id
}

output "public_subnet_ids" {
  description = "Public subnet IDs created by the network module."
  value       = [module.network.public-subnet-1-id, module.network.public-subnet-2-id]
}

output "private_subnet_ids" {
  description = "Private subnet IDs created by the network module."
  value       = [module.network.private-subnet-1-id, module.network.private-subnet-2-id]
}

output "frontend_alb_dns_name" {
  description = "DNS name of the frontend ALB."
  value       = module.compute.frontend_alb_dns_name
}

output "backend_alb_dns_name" {
  description = "DNS name of the backend internal ALB."
  value       = module.compute.backend_alb_dns_name
}

output "frontend_asg_name" {
  description = "Name of the frontend Auto Scaling group."
  value       = module.compute.frontend_asg_name
}

output "backend_asg_name" {
  description = "Name of the backend Auto Scaling group."
  value       = module.compute.backend_asg_name
}

output "db_instance_endpoint" {
  description = "RDS instance endpoint."
  value       = module.database.db_instance_endpoint
}

output "alerts_topic_arn" {
  description = "SNS topic ARN for alerts."
  value       = module.monitoring.alerts_topic_arn
}
