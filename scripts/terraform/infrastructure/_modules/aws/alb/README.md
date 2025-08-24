# ALB Module

This module creates an Application Load Balancer with HTTP/HTTPS listeners and security group.

## Features

- ✅ Application Load Balancer with configurable listeners
- ✅ Optional security group creation
- ✅ HTTP to HTTPS redirect support
- ✅ SSL/TLS termination
- ✅ Internal or internet-facing deployment
- ✅ Flexible CIDR block access control

## Usage

### Basic Internet-Facing ALB
```hcl
module "alb" {
  source     = "../_modules/alb"
  name       = "my-app-alb"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids
}
```

### ALB with HTTPS and Redirect
```hcl
module "alb" {
  source                = "../_modules/alb"
  name                  = "my-app-alb"
  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.vpc.public_subnet_ids
  enable_https          = true
  certificate_arn       = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
  redirect_http_to_https = true
  
  tags = {
    Environment = "production"
    Project     = "my-app"
  }
}
```

### Internal ALB with Custom Security Group
```hcl
module "alb" {
  source               = "../_modules/alb"
  name                 = "internal-alb"
  vpc_id               = module.vpc.vpc_id
  subnet_ids           = module.vpc.private_subnet_ids
  internal             = true
  create_security_group = false
  security_group_ids   = [aws_security_group.custom.id]
  allowed_cidr_blocks  = ["10.0.0.0/16"]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `name` | Name of the ALB | string | n/a | ✅ Yes |
| `vpc_id` | VPC ID where ALB will be deployed | string | n/a | ✅ Yes |
| `subnet_ids` | List of subnet IDs for ALB | list(string) | n/a | ✅ Yes |
| `internal` | Whether ALB is internal | bool | `false` | ❌ No |
| `enable_deletion_protection` | Enable deletion protection | bool | `false` | ❌ No |
| `create_security_group` | Whether to create security group | bool | `true` | ❌ No |
| `security_group_ids` | List of security group IDs | list(string) | `[]` | ❌ No |
| `allowed_cidr_blocks` | CIDR blocks allowed to access ALB | list(string) | `["0.0.0.0/0"]` | ❌ No |
| `enable_https` | Enable HTTPS listener | bool | `false` | ❌ No |
| `certificate_arn` | SSL certificate ARN for HTTPS | string | `null` | ❌ No* |
| `redirect_http_to_https` | Redirect HTTP to HTTPS | bool | `false` | ❌ No |
| `tags` | Tags to apply to resources | map(string) | `{}` | ❌ No |

## Outputs

| Name | Description |
|------|-------------|
| `alb_arn` | ARN of the ALB |
| `alb_dns_name` | DNS name of the ALB |
| `alb_zone_id` | Zone ID of the ALB |
| `http_listener_arn` | ARN of the HTTP listener |
| `https_listener_arn` | ARN of the HTTPS listener |
| `security_group_id` | ID of the ALB security group |

## Default Actions

- **HTTP Listener**: Returns 404 by default (or redirects to HTTPS if enabled)
- **HTTPS Listener**: Returns 404 by default

Use listener rules or target groups to route traffic to specific services.

## Notes

*`certificate_arn` is required when `enable_https` is `true`

## Requirements

- Terraform ≥ 1.0
- AWS Provider
- Configured AWS credentials