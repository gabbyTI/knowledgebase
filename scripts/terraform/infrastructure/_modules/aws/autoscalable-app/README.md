# autoscalable-app
This module manages the creation of an autoscalable AWS infrastructure for an application

## Submodules
- `iam`: Manages IAM roles and instance profiles.
- `security_groups`: Manages security groups for ALB and EC2 instances.
- `alb`: Manages the Application Load Balancer.
- `asg`: Manages the Auto Scaling Group and Launch Template.
- `autoscaler`: Manages CloudWatch alarms for auto-scaling.

### Links
- [IAM](./_modules/iam/README.md)
- [Security Groups](./_modules/security_groups/README.md)
- [Application Load Balancer](./_modules/alb/README.md)
- [Auto Scaling Group](./_modules/asg/README.md)
- [Auto Scaler](./_modules/autoscaler/README.md)

## Inputs
- `app_name`: Name of the application.
- `vpc_id`: ID of the VPC.
- `subnet_ids`: List of subnet IDs.
- `instance_type`: EC2 instance type.
- `desired_capacity`: Desired number of instances in ASG.
- `min_capacity`: Minimum number of instances in ASG.
- `max_capacity`: Maximum number of instances in ASG.
- `app_port`: Port where the application will be running on the instance.
- `certificate_arn`: ARN of the SSL certificate.
- `redirect_http_to_https`: Boolean to redirect HTTP to HTTPS.
- `environment`: Environment name (production or staging).
- `ami_id`: ID of the AMI to use for the instances.
- `user_data`: User data script to initialize the instance.

## Outputs
- `alb_dns_name`: DNS name of the load balancer.


