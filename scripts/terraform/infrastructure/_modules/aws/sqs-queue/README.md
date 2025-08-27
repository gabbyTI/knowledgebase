# SQS Queue Module

This module creates an SQS queue with optional dead letter queue (DLQ) for reliable message processing.

## Features

- ✅ Main SQS queue with configurable settings
- ✅ Optional dead letter queue for failed messages
- ✅ Configurable message retention and visibility timeout
- ✅ Automatic redrive policy configuration
- ✅ Flexible tagging support

## Usage

### Basic Queue
```hcl
module "my_queue" {
  source = "../_modules/sqs-queue"
  name   = "my-processing-queue"
}
```

### Queue with Custom Settings
```hcl
module "email_queue" {
  source = "../_modules/sqs-queue"
  
  name                       = "email-processing-queue"
  visibility_timeout_seconds = 60
  message_retention_seconds  = 604800  # 7 days
  max_receive_count         = 3
  
  tags = {
    Environment = "production"
    Purpose     = "email-processing"
  }
}
```

### Queue without DLQ
```hcl
module "simple_queue" {
  source = "../_modules/sqs-queue"
  
  name       = "simple-queue"
  create_dlq = false
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `name` | Name of the SQS queue | string | n/a | ✅ Yes |
| `visibility_timeout_seconds` | Visibility timeout in seconds | number | `30` | ❌ No |
| `message_retention_seconds` | Message retention period in seconds | number | `1209600` (14 days) | ❌ No |
| `create_dlq` | Whether to create a dead letter queue | bool | `true` | ❌ No |
| `max_receive_count` | Max receives before sending to DLQ | number | `5` | ❌ No |
| `dlq_message_retention_seconds` | DLQ message retention in seconds | number | `1209600` (14 days) | ❌ No |
| `tags` | Tags to apply to resources | map(string) | `{}` | ❌ No |

## Outputs

| Name | Description |
|------|-------------|
| `queue_arn` | ARN of the main SQS queue |
| `queue_id` | ID/URL of the main SQS queue |
| `queue_name` | Name of the main SQS queue |
| `dlq_arn` | ARN of the dead letter queue |
| `dlq_id` | ID/URL of the dead letter queue |
| `dlq_name` | Name of the dead letter queue |

## Dead Letter Queue

When `create_dlq = true` (default):
- Messages that fail processing after `max_receive_count` attempts are moved to DLQ
- DLQ has the same retention period as the main queue
- DLQ is automatically named `{queue-name}-dlq`

## Common Use Cases

- **Lambda processing**: Set visibility timeout > Lambda timeout
- **Batch processing**: Higher visibility timeout for longer processing
- **Email queues**: Moderate retry count (3-5) with DLQ for investigation
- **Critical workflows**: Always use DLQ to prevent message loss

## Requirements

- Terraform ≥ 1.0
- AWS Provider
- Configured AWS credentials