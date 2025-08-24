# security_groups
This submodule manages security groups for ALB and EC2 instances.

## Inputs
- `vpc_id`: VPC ID where security groups will be created.
- `app_name`: Application name used for naming resources.
- `allowed_ssh_cidr`: CIDR blocks allowed to SSH into EC2 instances.
- `app_port`: Port where the application will be running on the instance.
- `environment`: Environment name (production or staging).

## Outputs
- `alb_sg_id`: ID of the ALB security group.
- `instance_sg_id`: ID of the instance security group.
