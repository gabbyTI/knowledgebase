# Variables for AMI configuration
variable "app_name" {
  description = "Name of the application"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "iam_instance_profile" {
  description = "IAM instance profile name"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "desired_capacity" {
  description = "Desired number of instances in ASG"
  type        = number
}

variable "min_capacity" {
  description = "Minimum number of instances in ASG"
  type        = number
}

variable "max_capacity" {
  description = "Maximum number of instances in ASG"
  type        = number
}

variable "subnet_ids" {
  description = "List of subnet IDs for ASG"
  type        = list(string)
}

variable "target_group_arns" {
  description = "ARN of target group"
  type        = list(string)
}

variable "environment" {
  type        = string
  description = "Environment name"
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