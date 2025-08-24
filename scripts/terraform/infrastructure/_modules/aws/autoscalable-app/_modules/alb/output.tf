output "lb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.alb.dns_name
}

output "lb_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.alb.arn
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.tg.arn
}

#zoneid output
output "lb_zone_id" {
  description = "Zone ID of the Route 53 Hosted Zone"
  value       = aws_lb.alb.zone_id
}
