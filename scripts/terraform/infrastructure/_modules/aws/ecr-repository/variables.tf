variable "name" {
  type        = string
  description = "Name of the ECR repository"
}

variable "image_tag_mutability" {
  type        = string
  default     = "MUTABLE"
  description = "Image tag mutability setting for the repository (MUTABLE or IMMUTABLE, default is MUTABLE)"
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "Image tag mutability must be either MUTABLE or IMMUTABLE."
  }
}

variable "scan_on_push" {
  type        = bool
  default     = true
  description = "Enable vulnerability scanning on image push"
}

variable "lifecycle_policy_max_images" {
  type        = number
  default     = 10
  description = "Maximum number of images to keep"
}

variable "force_delete" {
  type        = bool
  default     = true
  description = "Allow repository deletion even if it contains images"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the repository"
}