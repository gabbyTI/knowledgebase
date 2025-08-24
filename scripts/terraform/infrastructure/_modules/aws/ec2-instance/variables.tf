# Add your variable declarations here

variable "name_prefix" {
  description = "The name to assign to the EC2 instance"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet in which to launch the EC2 instance"
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

variable "create_eip" {
  description = "Whether to create a Public Elastic IP for the EC2 instance"
  type        = bool
  default     = false
}

variable "user_data" {
  description = "User data script to run on instance launch"
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags for subnets"
  type        = map(string)
  default     = {}
}