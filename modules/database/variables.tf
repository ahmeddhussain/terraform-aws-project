variable "private_subnet_ids" {
  description = "List of private subnet IDs for the RDS subnet group."
  type        = list(string)
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
}

variable "db_allocated_storage" {
  description = "RDS allocated storage in GB."
  type        = number
}

variable "db_username" {
  description = "Master username for RDS."
  type        = string
}

variable "db_password" {
  description = "Master password for RDS."
  type        = string
  sensitive   = true
}

variable "db_sg_id" {
  description = "Security group ID used by RDS."
  type        = string
}

variable "environment" {
  description = "Deployment environment for resource tagging."
  type        = string
}
