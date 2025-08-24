variable "vpc_id" {
  description = "ID of the VPC where subnets will be created"
  type        = string
}

variable "base_cidr" {
  description = "Base CIDR block to subnet from"
  type        = string
}

variable "subnet_count" {
  description = "Number of subnets to create"
  type        = number
  default     = 1
}

variable "subnet_cidr_bits" {
  description = "Number of additional bits to extend the base CIDR"
  type        = number
  default     = 8
}

variable "cidr_offset" {
  description = "Offset for CIDR calculation to avoid conflicts"
  type        = number
  default     = 0
}

variable "name_prefix" {
  description = "Prefix for subnet names"
  type        = string
}

variable "map_public_ip_on_launch" {
  description = "Whether to assign public IP on launch"
  type        = bool
  default     = false
}

variable "route_table_id" {
  description = "Route table ID to associate with subnets"
  type        = string
  default     = null
  validation {
    condition     = var.create_route_table_association == false || (var.create_route_table_association == true && var.route_table_id != null)
    error_message = "route_table_id must be provided when create_route_table_association is true."
  }
}

variable "tags" {
  description = "Additional tags for subnets"
  type        = map(string)
  default     = {}
}

variable "create_route_table_association" {
  description = "Whether to create route table associations"
  type        = bool
  default     = true
}