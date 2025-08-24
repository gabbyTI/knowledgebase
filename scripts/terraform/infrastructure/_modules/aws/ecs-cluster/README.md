# ECS Cluster Module

This module creates an autoscalable ECS cluster with EC2 capacity provider and managed scaling.

## Features

- ✅ ECS cluster with EC2 capacity provider
- ✅ Auto Scaling Group with configurable capacity
- ✅ Managed scaling based on cluster utilization
- ✅ ECS-optimized AMI with automatic updates
- ✅ IAM roles and security groups
- ✅ Flexible tagging support

## Usage

### Basic ECS Cluster
```hcl
module "ecs_cluster" {
  source      = "../_modules/ecs-cluster"
  name_prefix = "my-app"
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.public_subnet_ids
}
```

### Production ECS Cluster
```hcl
module "ecs_cluster" {
  source           = "../_modules/ecs-cluster"
  name_prefix      = "production"
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.private_subnet_ids
  instance_type    = "t3.medium"
  min_capacity     = 2
  max_capacity     = 20
  desired_capacity = 4
  target_capacity  = 80
  
  tags = {
    Environment = "production"
    Project     = "my-app"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `name_prefix` | Name prefix for ECS cluster and resources | string | n/a | ✅ Yes |
| `vpc_id` | VPC ID where ECS cluster will be deployed | string | n/a | ✅ Yes |
| `subnet_ids` | List of subnet IDs for ECS instances | list(string) | n/a | ✅ Yes |
| `instance_type` | EC2 instance type for ECS instances | string | `"t3.micro"` | ❌ No |
| `min_capacity` | Minimum number of instances in ASG | number | `1` | ❌ No |
| `max_capacity` | Maximum number of instances in ASG | number | `10` | ❌ No |
| `desired_capacity` | Desired number of instances in ASG | number | `2` | ❌ No |
| `target_capacity` | Target capacity percentage for capacity provider | number | `75` | ❌ No |
| `tags` | Tags to apply to resources | map(string) | `{}` | ❌ No |
| `extra_user_data` | Additional user data script to append | string | `""` | ❌ No |
| `associate_public_ip_address` | Whether to associate a public IP address with instances | bool | `true` | ❌ No |

## Outputs

| Name | Description |
|------|-------------|
| `cluster_id` | ID of the ECS cluster |
| `cluster_name` | Name of the ECS cluster |
| `cluster_arn` | ARN of the ECS cluster |
| `capacity_provider_name` | Name of the capacity provider |
| `security_group_id` | ID of the ECS security group |
| `asg_name` | Name of the Auto Scaling Group |

## Capacity Provider

The module creates a capacity provider that:
- Automatically scales EC2 instances based on ECS task demand
- Maintains target capacity at specified percentage (default 75%)
- Uses managed scaling for optimal resource utilization
- Supports both scale-up and scale-down operations

## Security

- Security group allows internal VPC communication
- IAM role with minimal required permissions
- ECS-optimized AMI with latest security patches

## Requirements

- Terraform ≥ 1.0
- AWS Provider
- Configured AWS credentials