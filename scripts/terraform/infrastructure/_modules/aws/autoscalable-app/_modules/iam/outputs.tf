
# Output the IAM role ARN
output "iam_role_arn" {
  value       = aws_iam_role.ec2_role.arn
  description = "ARN of the IAM role created for EC2 instances"
}

# Output the IAM role name
output "iam_role_name" {
  value       = aws_iam_role.ec2_role.name
  description = "Name of the IAM role created for EC2 instances"
}

# Output the instance profile ARN
output "instance_profile_arn" {
  value       = aws_iam_instance_profile.instance_profile.arn
  description = "ARN of the instance profile for EC2 instances"
}

# Output the instance profile name
output "instance_profile_name" {
  value       = aws_iam_instance_profile.instance_profile.name
  description = "Name of the instance profile for EC2 instances"
}