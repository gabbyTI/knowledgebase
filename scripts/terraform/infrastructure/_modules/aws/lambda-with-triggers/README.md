# Lambda with Triggers Module

This module creates a Lambda function with optional trigger integrations (EventBridge, SQS, API Gateway).

## Features

- ✅ Lambda function with all standard configurations
- ✅ Optional EventBridge schedule trigger
- ✅ Optional SQS event source mapping
- ✅ Optional API Gateway integration
- ✅ Automatic permissions management

## Usage

### Basic Lambda (No Triggers)
```hcl
module "my_lambda" {
  source = "../_modules/lambda-with-triggers"
  
  name_prefix      = "my-function-dev"
  role_arn         = aws_iam_role.lambda_role.arn
  filename         = "placeholder.zip"
  source_code_hash = filebase64sha256("placeholder.zip")
  
  environment_variables = {
    API_URL = "https://api.example.com"
  }
}
```

### Lambda with EventBridge Schedule
```hcl
module "scheduled_lambda" {
  source = "../_modules/lambda-with-triggers"
  
  name_prefix         = "weekly-processor"
  role_arn            = aws_iam_role.lambda_role.arn
  filename            = "function.zip"
  source_code_hash    = filebase64sha256("function.zip")
  eventbridge_schedule = "cron(0 12 ? * MON *)"
}
```

### Lambda with SQS Trigger
```hcl
module "sqs_lambda" {
  source = "../_modules/lambda-with-triggers"
  
  name_prefix      = "queue-processor"
  role_arn         = aws_iam_role.lambda_role.arn
  filename         = "function.zip"
  source_code_hash = filebase64sha256("function.zip")
  
  sqs_trigger = {
    queue_arn  = aws_sqs_queue.my_queue.arn
    batch_size = 10
    enabled    = true
  }
}
```

### Lambda with Multiple Triggers
```hcl
module "multi_trigger_lambda" {
  source = "../_modules/lambda-with-triggers"
  
  name_prefix         = "multi-function"
  role_arn            = aws_iam_role.lambda_role.arn
  filename            = "function.zip"
  source_code_hash    = filebase64sha256("function.zip")
  
  eventbridge_schedule = "rate(5 minutes)"
  
  sqs_trigger = {
    queue_arn  = aws_sqs_queue.my_queue.arn
    batch_size = 5
    enabled    = true
  }
  
  api_gateway_trigger = {
    source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
  }
}
```

## Inputs

### Lambda Configuration
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `name_prefix` | Name prefix for Lambda function | string | n/a | ✅ Yes |
| `role_arn` | IAM role ARN for Lambda | string | n/a | ✅ Yes |
| `filename` | Path to deployment package | string | n/a | ✅ Yes |
| `source_code_hash` | SHA256 hash of package | string | n/a | ✅ Yes |
| `handler` | Lambda handler | string | `"lambda_function.lambda_handler"` | ❌ No |
| `runtime` | Lambda runtime | string | `"python3.12"` | ❌ No |
| `timeout` | Timeout in seconds | number | `30` | ❌ No |
| `memory_size` | Memory size in MB | number | `128` | ❌ No |
| `environment_variables` | Environment variables | map(string) | `{}` | ❌ No |
| `vpc_config` | VPC configuration | object | `null` | ❌ No |
| `tags` | Tags for resources | map(string) | `{}` | ❌ No |

### Trigger Configuration
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `eventbridge_schedule` | Schedule expression | string | `null` | ❌ No |
| `sqs_trigger` | SQS trigger config | object | `null` | ❌ No |
| `api_gateway_trigger` | API Gateway config | object | `null` | ❌ No |

## Outputs

| Name | Description |
|------|-------------|
| `function_name` | Lambda function name |
| `function_arn` | Lambda function ARN |
| `invoke_arn` | Lambda invoke ARN |
| `qualified_arn` | Lambda qualified ARN |
| `eventbridge_rule_arn` | EventBridge rule ARN (if created) |
| `sqs_event_source_mapping_uuid` | SQS mapping UUID (if created) |

## Requirements

- Terraform ≥ 1.0
- AWS Provider
- Configured AWS credentials