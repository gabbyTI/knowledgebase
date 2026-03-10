# ─── REQUIRED VARIABLES ────────────────────────────────────────────────────────

variable "environment" {
  type        = string
  description = "Deployment environment"
  validation {
    condition     = contains(["production", "staging"], var.environment)
    error_message = "Environment must be either 'production' or 'staging'."
  }
}

variable "github_pat" {
  type        = string
  sensitive   = true
  description = "GitHub Personal Access Token — used by Ansible to clone the app repo"
}

variable "app_repo" {
  type        = string
  description = "GitHub repository for the app in 'owner/repo-name' format"
}

# ─── OPTIONAL VARIABLES (with sensible defaults) ────────────────────────────────

variable "source_ami" {
  type        = string
  default     = ""  # If empty, Packer resolves the latest Ubuntu 24.04 arm64 via source_ami_filter
  description = "Source AMI ID. Leave empty to always use the latest Ubuntu 24.04 LTS."
}

variable "instance_type" {
  type        = string
  default     = "t4g.small"   # arm64 instance — change to t3.small for x86_64
  description = "EC2 instance type for the Packer build runner"
}

variable "project_dir_name" {
  type        = string
  default     = "myapp"   # <-- update: the directory the repo is cloned into
  description = "Name of the directory the app code will be cloned into on the server"
}

variable "s3_bucket_name" {
  type        = string
  default     = "myapp-envs-bucket"   # <-- update: your S3 bucket for env files
  description = "S3 bucket where environment files (.env) are stored, synced during AMI build"
}
