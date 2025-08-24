# ECR Repository Module

This module creates an AWS Elastic Container Registry (ECR) repository with automatic image scanning and lifecycle management.

## Features

- ✅ Automatic vulnerability scanning on push
- ✅ Lifecycle policy to manage image retention
- ✅ Mutable image tags for development flexibility
- ✅ Force delete enabled for easy cleanup

## Usage

### Basic Repository
```hcl
module "ecr" {
  source = "../_modules/ecr-repository"
  name   = "my-app"
}
```

### Production Repository (Immutable Tags)
```hcl
module "ecr" {
  source               = "../_modules/ecr-repository"
  name                 = "my-app"
  image_tag_mutability = "IMMUTABLE"
  lifecycle_policy_max_images = 50
  
  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `name` | Name of the ECR repository | string | n/a | ✅ Yes |
| `image_tag_mutability` | Image tag mutability setting | string | `"MUTABLE"` | ❌ No |
| `scan_on_push` | Enable vulnerability scanning on push | bool | `true` | ❌ No |
| `lifecycle_policy_max_images` | Maximum number of images to keep | number | `10` | ❌ No |
| `force_delete` | Allow repository deletion with images | bool | `true` | ❌ No |
| `tags` | Tags to apply to the repository | map(string) | `{}` | ❌ No |

## Outputs

| Name | Description |
|------|-------------|
| `repository_url` | URL of the ECR repository |
| `repository_arn` | ARN of the ECR repository |
| `repository_name` | Name of the ECR repository |
| `registry_id` | Registry ID where repository was created |

## Lifecycle Policy

The module automatically applies a lifecycle policy that:
- Keeps only the 10 most recent images
- Applies to all image tags (tagged and untagged)
- Helps manage storage costs by removing old images

## Requirements

- Terraform ≥ 1.0
- AWS Provider
- Configured AWS credentials