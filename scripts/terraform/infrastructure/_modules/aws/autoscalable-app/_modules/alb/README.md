# alb
This submodule manages the Application Load Balancer (ALB).

## Inputs
- `app_name`: Name of the application.
- `app_port`: Port where the application will be running on the instance.
- `security_groups`: List of security group IDs for the ALB.
- `subnet_ids`: List of subnet IDs for the ALB.
- `vpc_id`: ID of the VPC.
- `certificate_arn`: The ARN of the SSL certificate.
- `redirect_http_to_https`: Boolean to redirect HTTP to HTTPS.
- `environment`: Environment name (production or staging).

## Outputs
- `lb_dns_name`: DNS name of the load balancer.
- `lb_arn`: ARN of the load balancer.
- `target_group_arn`: ARN of the target group.
