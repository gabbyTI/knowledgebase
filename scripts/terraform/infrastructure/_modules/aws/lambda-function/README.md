# Lambda Function Module

A reusable Terraform module for creating AWS Lambda functions.

## Usage

```hcl
module "my_lambda" {
  source = "../../_modules/lambda-function"
  
  function_name = "my-function"
  role_arn      = aws_iam_role.lambda_role.arn
  filename      = "function.zip"
  source_code_hash = filebase64sha256("function.zip")
  
  environment_variables = {
    API_URL = "https://api.example.com"
    DEBUG   = "true"
  }
  
  tags = {
    Environment = "dev"
    Project     = "MyApp"
  }
}
```

## Variables

- `function_name`: Name of the Lambda function (required)
- `role_arn`: IAM role ARN for Lambda function (required)
- `filename`: Path to Lambda deployment package (required)
- `source_code_hash`: Base64-encoded SHA256 hash of the package file (required)
- `handler`: Lambda function handler (default: "lambda_function.lambda_handler")
- `runtime`: Lambda runtime (default: "python3.12")
- `timeout`: Lambda timeout in seconds (default: 30)
- `memory_size`: Lambda memory size in MB (default: 128)
- `environment_variables`: Environment variables map (default: {})
- `vpc_config`: VPC configuration object (default: null)
- `tags`: Tags map (default: {})

## Outputs

- `function_name`: Name of the Lambda function
- `function_arn`: ARN of the Lambda function
- `invoke_arn`: Invoke ARN of the Lambda function
- `qualified_arn`: Qualified ARN of the Lambda function