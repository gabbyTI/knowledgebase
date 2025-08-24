# autoscaler
This submodule manages CloudWatch alarms for auto-scaling.

## Inputs
- `app_name`: Name of the application.
- `scale_up_policy`: ARN of the Auto Scaling policy to scale up.
- `scale_down_policy`: ARN of the Auto Scaling policy to scale down.
- `environment`: Environment name (production or staging).

## Outputs
None
