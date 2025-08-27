output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.this.function_name
}

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.this.arn
}

output "invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = aws_lambda_function.this.invoke_arn
}

output "qualified_arn" {
  description = "Qualified ARN of the Lambda function"
  value       = aws_lambda_function.this.qualified_arn
}

output "eventbridge_rule_arn" {
  description = "ARN of the EventBridge rule (if created)"
  value       = var.eventbridge_schedule != null ? aws_cloudwatch_event_rule.schedule[0].arn : null
}

output "sqs_event_source_mapping_uuid" {
  description = "UUID of the SQS event source mapping (if created)"
  value       = var.sqs_trigger != null ? aws_lambda_event_source_mapping.sqs[0].uuid : null
}