variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "nat_ami" {
  description = "AMI ID for NAT instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for NAT instance"
  type        = string
  default     = "t3.micro"
}

variable "subnet_id" {
  description = "Subnet where NAT will live (public subnet)"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "eni_private_ip" {
  description = "Private IP to assign to ENI (optional)"
  type        = string
  default     = null
}

variable "eip_allocation_id" {
  description = "Optional existing EIP allocation ID"
  type        = string
  default     = null
}

variable "asg_min_size" {
  description = "Minimum size of ASG"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum size of ASG"
  type        = number
  default     = 1
}

variable "asg_desired_capacity" {
  description = "Desired capacity of ASG"
  type        = number
  default     = 1
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}