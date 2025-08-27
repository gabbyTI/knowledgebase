output "queue_arn" {
  description = "ARN of the main SQS queue"
  value       = aws_sqs_queue.main.arn
}

output "queue_id" {
  description = "ID/URL of the main SQS queue"
  value       = aws_sqs_queue.main.id
}

output "queue_name" {
  description = "Name of the main SQS queue"
  value       = aws_sqs_queue.main.name
}

output "dlq_arn" {
  description = "ARN of the dead letter queue"
  value       = var.create_dlq ? aws_sqs_queue.dlq[0].arn : null
}

output "dlq_id" {
  description = "ID/URL of the dead letter queue"
  value       = var.create_dlq ? aws_sqs_queue.dlq[0].id : null
}

output "dlq_name" {
  description = "Name of the dead letter queue"
  value       = var.create_dlq ? aws_sqs_queue.dlq[0].name : null
}