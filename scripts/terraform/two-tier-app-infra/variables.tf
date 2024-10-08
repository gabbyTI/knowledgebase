variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDR values"
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones"
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

variable "region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-2"
}

variable "db_username" {
  type        = string
  description = "Database Administrator Username"
  default     = "dbadmin"
}

variable "db_password" {
  type        = string
  description = "Database Administrator Password"
  default     = "dbadmin123"
}

