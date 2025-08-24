# iam
This submodule manages IAM roles and instance profiles.

## Inputs
- `app_name`: Name of the application.
- `environment`: Environment name (production or staging).

## Outputs
- `iam_role_arn`: ARN of the IAM role created for EC2 instances.
- `iam_role_name`: Name of the IAM role created for EC2 instances.
- `instance_profile_arn`: ARN of the instance profile for EC2 instances.
- `instance_profile_name`: Name of the instance profile for EC2 instances.
