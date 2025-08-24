output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.asg.name
}

output "asg_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.asg.arn
}

output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.lt.id
}

output "launch_template_version" {
  description = "Version of the launch template"
  value       = aws_launch_template.lt.latest_version
}

output "scale_up_policy" {
  description = "ARN of the Auto Scaling policy to scale up"
  value       = aws_autoscaling_policy.scale_up.arn
}

output "scale_down_policy" {
  description = "ARN of the Auto Scaling policy to scale down"
  value       = aws_autoscaling_policy.scale_down.arn
}
