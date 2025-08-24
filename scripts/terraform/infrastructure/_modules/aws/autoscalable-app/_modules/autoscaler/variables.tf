variable "app_name" {
  description = "Name of the application"
  type        = string
}

variable "scale_up_policy" {
  description = "ARN of the Auto Scaling policy to scale up"
  type        = string
}

variable "scale_down_policy" {
  description = "ARN of the Auto Scaling policy to scale down"
  type        = string
}

variable "asg_name" {
  description = "Auto Scaling Group resource"
  type        = string
}

variable "environment" {
  description = "Environment name (production or staging)"
  type        = string
  validation {
    condition     = contains(["production", "staging"], var.environment)
    error_message = "Environment must be either 'production' or 'staging'."
  }
}