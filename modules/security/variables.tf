variable "vpc_id" {
  description = "VPC ID where security groups are created."
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to connect over SSH."
  type        = string
}

variable "environment" {
  description = "Deployment environment used for naming and tags."
  type        = string
}