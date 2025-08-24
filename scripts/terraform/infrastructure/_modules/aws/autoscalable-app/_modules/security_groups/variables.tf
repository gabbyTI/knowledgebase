variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "app_name" {
  description = "Application name used for naming resources"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR blocks allowed to SSH into EC2 instances"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "app_port" {
  description = "Port where the application will be running on the instance"
  type        = number
}

variable "environment" {
  description = "Environment name (production or staging)"
  type        = string
  validation {
    condition     = contains(["production", "staging"], var.environment)
    error_message = "Environment must be either 'production' or 'staging'."
  }
}
