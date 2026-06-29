variable "vpc_id" {
  description = "VPC ID where security groups are created."
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to connect over SSH. Leave empty to disable SSH access."
  type        = string
  default     = ""

  validation {
    condition     = length(var.allowed_ssh_cidr) == 0 || can(cidrhost(var.allowed_ssh_cidr, 0))
    error_message = "allowed_ssh_cidr must be empty or a valid CIDR block."
  }
}

variable "environment" {
  description = "Deployment environment used for naming and tags."
  type        = string
}