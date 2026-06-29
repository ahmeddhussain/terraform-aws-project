output "frontend_asg_name" {
  description = "Name of the frontend Auto Scaling group."
  value       = aws_autoscaling_group.frontend.name
}

output "backend_asg_name" {
  description = "Name of the backend Auto Scaling group."
  value       = aws_autoscaling_group.backend.name
}

output "frontend_alb_dns_name" {
  description = "DNS name of the frontend ALB."
  value       = aws_lb.frontend.dns_name
}

output "backend_alb_dns_name" {
  description = "DNS name of the backend ALB."
  value       = aws_lb.backend.dns_name
}
