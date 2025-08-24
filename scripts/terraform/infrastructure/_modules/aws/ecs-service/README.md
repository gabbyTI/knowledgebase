# ECS Service Module

This module creates an ECS service with task definition using capacity providers from the ECS cluster module.

## Features

- ✅ Creates both task definition and ECS service
- ✅ Uses capacity providers (from ECS cluster module)
- ✅ Optional ALB target group creation
- ✅ Optional ALB listener rule for path-based routing
- ✅ Configurable health check settings
- ✅ Optional ECS service autoscaling
- ✅ CloudWatch logging integration

## Usage

### Basic ECS Service
```hcl
module "ecs_service" {
  source = "../_modules/ecs-service"
  
  service_name            = "my-app"
  cluster_arn             = module.ecs_cluster.cluster_arn
  capacity_provider_name  = module.ecs_cluster.capacity_provider_name
  
  # Task Definition
  family          = "my-app-task"
  image           = "nginx:latest"
  container_name  = "app"
  container_port  = 80
  cpu             = 256
  memory          = 512
  
  # Load Balancer
  vpc_id = module.vpc.vpc_id
}
```

### Service with Autoscaling
```hcl
module "ecs_service" {
  source = "../_modules/ecs-service"
  
  service_name            = "my-app"
  cluster_arn             = module.ecs_cluster.cluster_arn
  capacity_provider_name  = module.ecs_cluster.capacity_provider_name
  
  # Task Definition
  family          = "my-app-task"
  image           = "my-app:latest"
  container_name  = "app"
  container_port  = 3000
  cpu             = 512
  memory          = 1024
  
  environment_variables = {
    NODE_ENV = "production"
    PORT     = "3000"
  }
  
  # Load Balancer
  vpc_id = module.vpc.vpc_id
  
  # Autoscaling
  enable_autoscaling      = true
  min_capacity           = 2
  max_capacity           = 10
  target_cpu_utilization = 70
  
  tags = {
    Environment = "production"
    Project     = "my-app"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `service_name` | Name of the ECS service | string | n/a | ✅ Yes |
| `cluster_arn` | ARN of the ECS cluster | string | n/a | ✅ Yes |
| `capacity_provider_name` | Name of the capacity provider | string | n/a | ✅ Yes |
| `family` | Task definition family name | string | n/a | ✅ Yes |
| `image` | Docker image for the container | string | n/a | ✅ Yes |
| `container_name` | Name of the container | string | n/a | ✅ Yes |
| `container_port` | Port the container listens on | number | n/a | ✅ Yes |
| `desired_count` | Desired number of tasks | number | `2` | ❌ No |
| `cpu` | CPU units for the task | number | `256` | ❌ No |
| `memory` | Memory in MB for the task | number | `512` | ❌ No |
| `task_role_arn` | ARN of the task role | string | `null` | ❌ No |
| `execution_role_arn` | ARN of the execution role | string | `null` | ❌ No |
| `environment_variables` | Environment variables | map(string) | `{}` | ❌ No |
| `create_target_group` | Whether to create a new target group | bool | `true` | ❌ No |
| `vpc_id` | VPC ID for target group | string | `null` | ❌ No* |
| ` ` | Health check path | string | `"/"` | ❌ No |
| `enable_autoscaling` | Enable ECS service autoscaling | bool | `false` | ❌ No |
| `min_capacity` | Minimum number of tasks | number | `1` | ❌ No |
| `max_capacity` | Maximum number of tasks | number | `10` | ❌ No |
| `target_cpu_utilization` | Target CPU utilization percentage | number | `70` | ❌ No |
| `tags` | Tags to apply to resources | map(string) | `{}` | ❌ No |

## Outputs

| Name | Description |
|------|-------------|
| `service_name` | Name of the ECS service |
| `service_arn` | ARN of the ECS service |
| `task_definition_arn` | ARN of the task definition |
| `target_group_arn` | ARN of the target group |
| `listener_rule_arn` | ARN of the listener rule (if created) |

## Notes

*`vpc_id` is required when `create_target_group` is `true`

## Requirements

- Terraform ≥ 1.0
- AWS Provider
- ECS Cluster with capacity provider (from ecs-cluster module)