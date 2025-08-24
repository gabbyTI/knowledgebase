variable "app_name" {
  description = "Name of the application"
  type        = string
}
variable "app_port" {
  description = "Port where the application will be running on the instance"
  type        = number
}

variable "security_groups" {
  description = "List of security group IDs for the ALB"
  type        = list(string)
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ALB"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "certificate_arn" {
  description = "The ARN of the SSL certificate"
  type        = string
  validation {
    condition     = var.redirect_http_to_https == false || (var.certificate_arn != "" && var.certificate_arn != null)
    error_message = "certificate_arn must be provided when create_https_listener is true"
  }
}

variable "redirect_http_to_https" {
  description = "Boolean to redirect HTTP to HTTPS"
  type        = bool
  default     = false
}

variable "environment" {
  description = "Environment name (production or staging)"
  type        = string
  validation {
    condition     = contains(["production", "staging"], var.environment)
    error_message = "Environment must be either 'production' or 'staging'."
  }
}