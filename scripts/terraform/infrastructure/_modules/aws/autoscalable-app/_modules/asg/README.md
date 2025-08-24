# asg
This submodule manages the Auto Scaling Group (ASG) and Launch Template.

## Inputs
- `app_name`: Name of the application.
- `instance_type`: EC2 instance type.
- `iam_instance_profile`: IAM instance profile name.
- `security_group_ids`: List of security group IDs.
- `desired_capacity`: Desired number of instances in ASG.
- `min_capacity`: Minimum number of instances in ASG.
- `max_capacity`: Maximum number of instances in ASG.
- `subnet_ids`: List of subnet IDs for ASG.
- `target_group_arns`: ARN of target group.
- `environment`: Environment name (production or staging).
- `ami_id`: ID of the AMI to use for the instances.
- `user_data`: User data script to initialize the instance.

## Outputs
- `asg_name`: Name of the Auto Scaling Group.
- `asg_arn`: ARN of the Auto Scaling Group.
- `launch_template_id`: ID of the launch template.
- `launch_template_version`: Version of the launch template.
- `scale_up_policy`: ARN of the Auto Scaling policy to scale up.
- `scale_down_policy`: ARN of the Auto Scaling policy to scale down.
