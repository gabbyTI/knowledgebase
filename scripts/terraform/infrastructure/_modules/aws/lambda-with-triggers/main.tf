# Lambda Function
resource "aws_lambda_function" "this" {
  function_name = "${var.name_prefix}-lambda"
  handler       = var.handler
  runtime       = var.runtime
  role          = var.role_arn
  timeout       = var.timeout
  memory_size   = var.memory_size

  filename         = var.filename
  source_code_hash = var.source_code_hash

  dynamic "environment" {
    for_each = length(var.environment_variables) > 0 ? [1] : []
    content {
      variables = var.environment_variables
    }
  }

  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [var.vpc_config] : []
    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  tags = var.tags
}

# EventBridge Schedule Trigger
resource "aws_cloudwatch_event_rule" "schedule" {
  count = var.eventbridge_schedule != null ? 1 : 0
  
  name                = "${var.name_prefix}-schedule"
  schedule_expression = var.eventbridge_schedule
  
  tags = var.tags
}

resource "aws_cloudwatch_event_target" "lambda" {
  count = var.eventbridge_schedule != null ? 1 : 0
  
  rule = aws_cloudwatch_event_rule.schedule[0].name
  arn  = aws_lambda_function.this.arn
}

resource "aws_lambda_permission" "eventbridge" {
  count = var.eventbridge_schedule != null ? 1 : 0
  
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule[0].arn
}

# SQS Event Source Mapping
resource "aws_lambda_event_source_mapping" "sqs" {
  count = var.sqs_trigger != null ? 1 : 0
  
  event_source_arn = var.sqs_trigger.queue_arn
  function_name    = aws_lambda_function.this.arn
  batch_size       = var.sqs_trigger.batch_size
  enabled          = var.sqs_trigger.enabled
}

# API Gateway Integration
resource "aws_lambda_permission" "api_gateway" {
  count = var.api_gateway_trigger != null ? 1 : 0
  
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = var.api_gateway_trigger.source_arn
}