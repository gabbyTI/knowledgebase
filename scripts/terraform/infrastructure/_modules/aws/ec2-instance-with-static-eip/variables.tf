# Add your variable declarations here

variable "instance_name" {
  description = "The name to assign to the EC2 instance"
  type        = string
}

variable "ami" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
}

variable "security_group_ids" {
  description = "Security group ID for the EC2 instance"
  type        = set(string)
}

variable "environment" {
  description = "The environment for the EC2 instance (e.g., dev, staging, prod)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = null
}