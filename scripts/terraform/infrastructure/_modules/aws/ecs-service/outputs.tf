output "service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.this.name
}

output "service_arn" {
  description = "ARN of the ECS service"
  value       = aws_ecs_service.this.id
}

output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = aws_ecs_task_definition.this.arn
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = var.create_target_group ? aws_lb_target_group.this[0].arn : var.target_group_arn
}

output "listener_rule_arn" {
  description = "ARN of the listener rule (if created)"
  value       = var.create_listener_rule ? aws_lb_listener_rule.this[0].arn : null
}

output "autoscaling_target_resource_id" {
  description = "Resource ID of the autoscaling target"
  value       = var.enable_autoscaling ? aws_appautoscaling_target.this[0].resource_id : null
}