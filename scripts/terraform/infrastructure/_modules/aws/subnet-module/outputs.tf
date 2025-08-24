output "subnet_ids" {
  description = "List of subnet IDs"
  value       = aws_subnet.subnet[*].id
}

output "subnet_cidrs" {
  description = "List of subnet CIDR blocks"
  value       = aws_subnet.subnet[*].cidr_block
}

output "availability_zones" {
  description = "List of availability zones used"
  value       = aws_subnet.subnet[*].availability_zone
}