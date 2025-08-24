# RDS PostgreSQL Module

A simple and minimal Terraform module for creating an AWS RDS PostgreSQL database instance.

## Features

- **Minimal and Simple**: Only essential resources for a PostgreSQL database
- **Secure by Default**: Encryption at rest with KMS, VPC security groups
- **Easy to Use**: Simple variable interface, consistent naming
- **Production Ready**: Suitable for development and production environments

## Resources Created

- AWS RDS PostgreSQL instance
- DB subnet group for multi-AZ deployment
- Security group with PostgreSQL port (5432) access
- KMS key for encryption at rest
- AWS Secrets Manager secret for database credentials
- Random password generation (if password not provided)

## Usage

```hcl
module "postgres_db" {
  source = "./rds-postgres-module"

  # Basic Configuration
  name_prefix        = "myapp"
  vpc_id             = "vpc-12345678"
  vpc_cidr           = "10.0.0.0/16"
  private_subnet_ids = ["subnet-12345678", "subnet-87654321"]

  # Database Configuration
  database_name    = "myapp_db"
  db_username      = "myapp_user"
  # db_password    = "***********"  # Optional - if not provided, will be generated
  postgres_version = "15.4"
  instance_class   = "db.t3.micro"

  # Storage Configuration
  allocated_storage = 20

  # Tags
  tags = {
    Environment = "development"
    Project     = "MyApp"
  }
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `name_prefix` | Prefix for all resource names | `string` | n/a | yes |
| `vpc_id` | VPC ID where the database will be created | `string` | n/a | yes |
| `vpc_cidr` | CIDR block of the VPC for security group rules | `string` | n/a | yes |
| `private_subnet_ids` | List of private subnet IDs for the database | `list(string)` | n/a | yes |
| `database_name` | Name of the database to create | `string` | n/a | yes |
| `db_username` | Username for the database | `string` | n/a | yes |
| `db_password` | Password for the database (if not provided, will be generated) | `string` | `null` | no |
| `postgres_version` | PostgreSQL version | `string` | `"15.4"` | no |
| `instance_class` | Database instance class | `string` | `"db.t3.micro"` | no |
| `allocated_storage` | Allocated storage in GB | `number` | `20` | no |
| `skip_final_snapshot` | Skip final snapshot when deleting | `bool` | `true` | no |
| `tags` | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `endpoint` | The PostgreSQL database endpoint |
| `port` | The PostgreSQL database port |
| `database_name` | The name of the PostgreSQL database |
| `username` | The PostgreSQL database username |
| `security_group_id` | The ID of the security group for the database |
| `connection_string` | PostgreSQL connection string (sensitive) |
| `secrets_manager_secret_id` | Secrets Manager secret ID containing database credentials |
| `secrets_manager_secret_arn` | Secrets Manager secret ARN containing database credentials |

## Security

- Database is encrypted at rest using AWS KMS
- Database is only accessible from within the VPC
- Security group allows access only on PostgreSQL port (5432)
- Database credentials are stored securely in AWS Secrets Manager
- Random password generation if no password is provided
- Connection string output is marked as sensitive

## Notes

- This module creates a minimal PostgreSQL RDS instance
- For production use, consider additional features like:
  - Multi-AZ deployment
  - Read replicas
  - Enhanced monitoring
  - Backup configuration
  - Parameter groups
