# General VPC Configuration
variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_count" {
  description = "Number of public subnets"
  type        = number
  default     = 2
}

variable "private_subnet_count" {
  description = "Number of private subnets"
  type        = number
  default     = 2
}

variable "create_nat_gateway" {
  description = "Whether to create a NAT Gateway"
  type        = bool
  default     = true
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}
