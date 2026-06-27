variable "frontend_asg_name" {
  description = "Name of the frontend Auto Scaling group."
  type        = string
}

variable "backend_asg_name" {
  description = "Name of the backend Auto Scaling group."
  type        = string
}

variable "alert_email" {
  description = "Email address for CloudWatch alarm notifications."
  type        = string
}

variable "environment" {
  description = "Deployment environment for resource tagging."
  type        = string
}
