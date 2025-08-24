# VPC Module

This module creates a production-ready AWS VPC with public and private subnets across all available AZs.

## Features

- ✅ Multi-AZ deployment (1 subnet per AZ)
- ✅ Optional NAT Gateway for private subnet internet access
- ✅ Internet Gateway for public subnet access
- ✅ Automatic CIDR calculation
- ✅ Route tables and associations
- ✅ Flexible tagging support

## Usage

### Basic VPC (No NAT Gateway)
```hcl
module "vpc" {
  source      = "../_modules/vpc-module"
  name_prefix = "my-app"
  vpc_cidr    = "10.0.0.0/16"
}
```

### VPC with NAT Gateway
```hcl
module "vpc" {
  source             = "../_modules/vpc-module"
  name_prefix        = "my-app"
  vpc_cidr           = "10.0.0.0/16"
  create_nat_gateway = true
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `name_prefix` | Prefix for resource names | string | n/a | ✅ Yes |
| `vpc_cidr` | CIDR block for the VPC | string | n/a | ✅ Yes |
| `public_subnet_cidr_bits` | Additional bits for public subnets | number | `8` | ❌ No |
| `private_subnet_cidr_bits` | Additional bits for private subnets | number | `8` | ❌ No |
| `create_nat_gateway` | Create NAT Gateway for private subnets | bool | `false` | ❌ No |
| `public_subnet_cidr_offset` | Offset for public subnet CIDR calculation | number | `0` | ❌ No |
| `private_subnet_cidr_offset` | Offset for private subnet CIDR calculation | number | `10` | ❌ No |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | ID of the VPC |
| `vpc_cidr` | CIDR block of the VPC |
| `public_subnet_ids` | List of public subnet IDs |
| `private_subnet_ids` | List of private subnet IDs |
| `public_subnets_cidr_blocks` | List of public subnet CIDR blocks |
| `private_subnets_cidr_blocks` | List of private subnet CIDR blocks |
| `internet_gateway_id` | ID of the Internet Gateway |
| `public_route_table_id` | ID of the public route table |
| `private_route_table_id` | ID of the private route table |

## CIDR Calculation

Subnets are automatically calculated using `cidrsubnet()`:

**Example with `vpc_cidr = "10.0.0.0/16"` and `cidr_bits = 8`:**
- Public subnets: `10.0.0.0/24`, `10.0.1.0/24`, `10.0.2.0/24`
- Private subnets: `10.0.10.0/24`, `10.0.11.0/24`, `10.0.12.0/24`

## Requirements

- Terraform ≥ 1.0
- AWS Provider
- Configured AWS credentials