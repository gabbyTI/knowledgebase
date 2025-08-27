variable "name_prefix" {
  description = "Name prefix for the SQS queue"
  type        = string
}

variable "visibility_timeout_seconds" {
  description = "Visibility timeout for the queue in seconds"
  type        = number
  default     = 30
}

variable "message_retention_seconds" {
  description = "Message retention period in seconds"
  type        = number
  default     = 1209600 # 14 days
}

variable "create_dlq" {
  description = "Whether to create a dead letter queue"
  type        = bool
  default     = true
}

variable "max_receive_count" {
  description = "Maximum number of times a message can be received before being sent to DLQ"
  type        = number
  default     = 5
}

variable "dlq_message_retention_seconds" {
  description = "Message retention period for DLQ in seconds"
  type        = number
  default     = 1209600 # 14 days
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}