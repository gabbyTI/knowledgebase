variable "name_prefix" {
  description = "Name prefix for the IAM role"
  type        = string
}

variable "assume_role_policy" {
  description = "JSON policy document for assume role"
  type        = string
}

variable "managed_policy_arns" {
  description = "List of AWS managed policy ARNs to attach"
  type        = list(string)
  default     = []
}

variable "inline_policies" {
  description = "Map of inline policies to attach"
  type = map(object({
    policy = string
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to the role"
  type        = map(string)
  default     = {}
}