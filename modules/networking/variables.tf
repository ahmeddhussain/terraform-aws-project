variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}
variable "public_subnet_1_cidr" {
  description = "The CIDR block for the first public subnet"
  type        = string
}
variable "public_subnet_2_cidr" {
  description = "The CIDR block for the second public subnet"
  type        = string
}
variable "private_subnet_1_cidr" {
  description = "The CIDR block for the first private subnet"
  type        = string
}
variable "private_subnet_2_cidr" {
  description = "The CIDR block for the second private subnet"
  type        = string
}

variable "environment" {
  description = "Deployment environment used for resource tagging."
  type        = string
}
