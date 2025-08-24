variable "app_name" {}
variable "vpc_id" {}
variable "subnet_ids" { type = list(string) }
variable "instance_type" { default = "t3.medium" }
variable "desired_capacity" { default = 2 }
variable "min_capacity" { default = 1 }
variable "max_capacity" { default = 3 }
variable "app_port" { type = number }
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
  type        = string
  description = "Environment name (production or staging)"
  validation {
    condition     = contains(["production", "staging"], var.environment)
    error_message = "Environment must be either 'production' or 'staging'."
  }
}

variable "ami_id" {
  description = "ID of the AMI to use for the instances"
  type        = string
}

variable "user_data" {
  description = "User data script to initialize the instance"
  type        = string
  default     = ""
}
