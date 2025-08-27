# IAM Role Module

This module creates an IAM role with managed and inline policy attachments.

## Features

- ✅ IAM role with configurable assume role policy
- ✅ Multiple AWS managed policy attachments
- ✅ Multiple inline policy attachments
- ✅ Flexible tagging support

## Usage

### Basic Lambda Role
```hcl
module "lambda_role" {
  source = "../_modules/iam-role"
  
  name = "my-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
  
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
}
```

### Role with Custom Policies
```hcl
module "lambda_role" {
  source = "../_modules/iam-role"
  
  name = "lambda-unverified-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
  
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
  
  inline_policies = {
    sqs_permissions = {
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect   = "Allow"
            Action   = ["sqs:SendMessage", "sqs:ReceiveMessage"]
            Resource = "arn:aws:sqs:*:*:my-queue"
          }
        ]
      })
    }
    ses_permissions = {
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect   = "Allow"
            Action   = ["ses:SendEmail", "ses:SendRawEmail"]
            Resource = "*"
          }
        ]
      })
    }
  }
  
  tags = {
    Environment = "production"
    Purpose     = "lambda-execution"
  }
}
```

### EC2 Role
```hcl
module "ec2_role" {
  source = "../_modules/iam-role"
  
  name = "my-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
  
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `name` | Name of the IAM role | string | n/a | ✅ Yes |
| `assume_role_policy` | JSON policy document for assume role | string | n/a | ✅ Yes |
| `managed_policy_arns` | List of AWS managed policy ARNs | list(string) | `[]` | ❌ No |
| `inline_policies` | Map of inline policies | map(object) | `{}` | ❌ No |
| `tags` | Tags to apply to the role | map(string) | `{}` | ❌ No |

## Outputs

| Name | Description |
|------|-------------|
| `role_arn` | ARN of the IAM role |
| `role_name` | Name of the IAM role |
| `role_id` | ID of the IAM role |

## Common Assume Role Policies

### Lambda
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Action": "sts:AssumeRole",
    "Effect": "Allow",
    "Principal": {
      "Service": "lambda.amazonaws.com"
    }
  }]
}
```

### EC2
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Action": "sts:AssumeRole",
    "Effect": "Allow",
    "Principal": {
      "Service": "ec2.amazonaws.com"
    }
  }]
}
```

### ECS Task
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Action": "sts:AssumeRole",
    "Effect": "Allow",
    "Principal": {
      "Service": "ecs-tasks.amazonaws.com"
    }
  }]
}
```

## Requirements

- Terraform ≥ 1.0
- AWS Provider
- Configured AWS credentials