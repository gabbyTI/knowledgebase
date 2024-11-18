# Auto Scaling Group
# Launch Template for EC2 Instances
resource "aws_launch_template" "app" {
  name_prefix   = "app-launch-template"
  image_id      = "ami-085f9c64a9b75eed5" # Replace with your region's AMI ID
  instance_type = "t2.micro"
  monitoring {
    enabled = true
  }
  # key_name = "your-key" # SSH key to access the EC2 instance

  # iam_instance_profile {
  #   name = "your-instance-profile"
  # }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.web_sg.id]
    subnet_id                   = aws_subnet.public[0].id
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "WebServer"
    }
  }

  # user_data is base64 value of the ./script file
  user_data = filebase64("${path.module}/script")
}
resource "aws_autoscaling_group" "app_asg" {
  desired_capacity    = 5
  max_size            = 15
  min_size            = 1
  vpc_zone_identifier = [for subnet in aws_subnet.public : subnet.id]

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest" # Always use the latest version of the template
  }

  target_group_arns = [aws_lb_target_group.app_lb_tg.arn]

  tag {
    key                 = "Name"
    value               = "WebServer"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale_up_policy"
  scaling_adjustment     = 1 # Add 1 instance
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale_down_policy"
  scaling_adjustment     = -1 # Remove 1 instance
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "cpu_high_alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70                                    # Scale up when CPU > 70%
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn] # Trigger scale-up action
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "cpu_low_alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 30                                      # Scale down when CPU < 30%
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn] # Trigger scale-down action
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }
}