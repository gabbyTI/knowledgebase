# Dead Letter Queue (optional)
resource "aws_sqs_queue" "dlq" {
  count = var.create_dlq ? 1 : 0

  name                      = "${var.name_prefix}-sqs-dlq"
  message_retention_seconds = var.dlq_message_retention_seconds

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-sqs-dlq"
    Type = "DeadLetterQueue"
  })
}

# Main SQS Queue
resource "aws_sqs_queue" "main" {
  name                       = "${var.name_prefix}-sqs"
  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = var.message_retention_seconds
  redrive_policy = var.create_dlq ? jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[0].arn
    maxReceiveCount     = var.max_receive_count
  }) : null


  tags = merge(var.tags, {
    Name = "${var.name_prefix}-sqs"
    Type = "MainQueue"
  })
}