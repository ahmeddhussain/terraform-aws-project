variable "public_subnet_ids" {
  description = "List of public subnets for the frontend ALB and ASG."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnets for the backend ALB and ASG."
  type        = list(string)
}

variable "vpc_id" {
  description = "ID of the VPC where compute resources are deployed."
  type        = string
}

variable "frontend_sg_id" {
  description = "Security group ID for the frontend EC2 instances."
  type        = string
}

variable "backend_sg_id" {
  description = "Security group ID for the backend EC2 instances."
  type        = string
}

variable "backend_alb_sg_id" {
  description = "Security group ID for the backend internal ALB."
  type        = string
}

variable "alb_sg_id" {
  description = "Security group ID for the frontend ALB."
  type        = string
}

variable "alb_name" {
  description = "Name of the frontend application load balancer."
  type        = string
}

variable "alb_type" {
  description = "Type of frontend ALB."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for frontend instances."
  type        = string
}

variable "backend_instance_type" {
  description = "EC2 instance type for backend instances."
  type        = string
}

variable "key_pair_name" {
  description = "EC2 key pair name for SSH access."
  type        = string
}

variable "min_size" {
  description = "Minimum number of ASG instances."
  type        = number
}

variable "desired_capacity" {
  description = "Desired number of ASG instances."
  type        = number
}

variable "max_size" {
  description = "Maximum number of ASG instances."
  type        = number
}

variable "environment" {
  description = "Deployment environment for resource tagging."
  type        = string
}
