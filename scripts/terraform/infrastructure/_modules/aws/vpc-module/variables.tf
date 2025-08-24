variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr_bits" {
  description = "CIDR subnet bits for public subnets"
  type        = number
  default     = 8
}

variable "private_subnet_cidr_bits" {
  description = "CIDR subnet bits for private subnets"
  type        = number
  default     = 8
}

variable "create_nat_gateway" {
  description = "Flag to create a NAT Gateway"
  type        = bool
  default     = false
}

variable "public_subnet_cidr_offset" {
  description = "Offset for public subnet CIDR calculation"
  type        = number
  default     = 0
}

variable "private_subnet_cidr_offset" {
  description = "Offset for private subnet CIDR calculation"
  type        = number
  default     = 10
}
