# Core ECS Service Configuration
variable "service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "cluster_arn" {
  description = "ARN of the ECS cluster"
  type        = string
}

variable "capacity_provider_name" {
  description = "Name of the capacity provider to use"
  type        = string
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 2
}

# Task Definition Configuration
variable "family" {
  description = "Task definition family name"
  type        = string
}

variable "cpu" {
  description = "CPU units for the task (256, 512, 1024, etc.)"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Memory in MB for the task"
  type        = number
  default     = 512
}

variable "image" {
  description = "Docker image for the container"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the task role"
  type        = string
  default     = null
}

variable "execution_role_arn" {
  description = "ARN of the execution role."
  type        = string
  default     = null
}

variable "environment_variables" {
  description = "Environment variables for the container"
  type        = map(string)
  default     = {}
}

# Container Configuration
variable "container_name" {
  description = "Name of the container in the task definition"
  type        = string
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
}

# Load Balancer Configuration
variable "create_target_group" {
  description = "Whether to create a new target group"
  type        = bool
  default     = true
}

variable "target_group_arn" {
  description = "ARN of existing target group (used when create_target_group is false)"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "VPC ID for target group (required when creating target group)"
  type        = string
  default     = null
}

variable "target_group_protocol" {
  description = "Protocol for target group"
  type        = string
  default     = "HTTP"
}

variable "target_group_port" {
  description = "Port for target group"
  type        = number
  default     = 80
}

# Health Check Configuration
variable "health_check_enabled" {
  description = "Enable health checks"
  type        = bool
  default     = true
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/"
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "healthy_threshold" {
  description = "Number of consecutive successful health checks"
  type        = number
  default     = 2
}

variable "unhealthy_threshold" {
  description = "Number of consecutive failed health checks"
  type        = number
  default     = 3
}

# ALB Listener Rule Configuration
variable "create_listener_rule" {
  description = "Whether to create ALB listener rule"
  type        = bool
  default     = false
}

variable "listener_arn" {
  description = "ARN of the ALB listener"
  type        = string
  default     = null
}

variable "listener_rule_priority" {
  description = "Priority for the listener rule"
  type        = number
  default     = 100
}

variable "path_patterns" {
  description = "Path patterns for listener rule"
  type        = list(string)
  default     = ["/api/*"]
}

# Auto Scaling Configuration
variable "enable_autoscaling" {
  description = "Enable ECS service autoscaling"
  type        = bool
  default     = false
}

variable "min_capacity" {
  description = "Minimum number of tasks"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum number of tasks"
  type        = number
  default     = 10
}

variable "target_cpu_utilization" {
  description = "Target CPU utilization percentage for autoscaling"
  type        = number
  default     = 70
}

variable "scale_up_cooldown" {
  description = "Scale up cooldown in seconds"
  type        = number
  default     = 300
}

variable "scale_down_cooldown" {
  description = "Scale down cooldown in seconds"
  type        = number
  default     = 300
}



# Tags
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}