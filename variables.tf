variable "aws_region" {
  description = "AWS region used for all resources."
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "AWS region must follow the format 'us-east-1'."
  }
}

variable "environment" {
  description = "Deployment environment name for tagging and naming."
  type        = string
  default     = "dev"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.environment))
    error_message = "Environment name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for the first public subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for the second public subnet."
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_1_cidr" {
  description = "CIDR block for the first private subnet."
  type        = string
  default     = "10.0.3.0/24"
}

variable "private_subnet_2_cidr" {
  description = "CIDR block for the second private subnet."
  type        = string
  default     = "10.0.4.0/24"
}

variable "instance_type" {
  description = "EC2 instance type for the web application."
  type        = string
  default     = "t3.micro"
}

variable "backend_instance_type" {
  description = "EC2 instance type for backend application servers."
  type        = string
  default     = "t3.micro"
}

variable "key_pair_name" {
  description = "EC2 key pair name for SSH access."
  type        = string
  default     = "ahmed"
}

variable "alb_name" {
  description = "Name for the application load balancer."
  type        = string
  default     = "app-alb"
}

variable "alb_type" {
  description = "ALB type used by the load balancer."
  type        = string
  default     = "application"
}

variable "min_size" {
  description = "Minimum number of Auto Scaling group instances."
  type        = number
  default     = 1
}

variable "desired_capacity" {
  description = "Desired number of Auto Scaling group instances."
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of Auto Scaling group instances."
  type        = number
  default     = 3
}

variable "db_instance_class" {
  description = "RDS instance class for the database."
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage size in GB for the database."
  type        = number
  default     = 20
}

variable "db_username" {
  description = "Database master username."
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Database master password."
  type        = string
  default     = "admin"
}

variable "alert_email" {
  description = "Email address for CloudWatch alarm notifications."
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into EC2 instances."
  type        = string
  default     = "0.0.0.0/0" #Make it your public IP address with /32 for security reasons.

  validation {
    condition     = can(cidrhost(var.allowed_ssh_cidr, 0))
    error_message = "allowed_ssh_cidr must be a valid CIDR block."
  }
}
