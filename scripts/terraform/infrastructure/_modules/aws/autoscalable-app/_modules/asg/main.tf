resource "aws_launch_template" "lt" {
  name_prefix   = "${var.app_name}-${var.environment}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = var.security_group_ids
    delete_on_termination       = true
    # ipv6_addresscount          = 1
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.app_name}-${var.environment}-instance"
      Environment = var.environment
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  user_data = base64encode(var.user_data)
}

resource "aws_autoscaling_group" "asg" {
  name_prefix         = "${var.app_name}-${var.environment}-asg-"
  desired_capacity    = var.desired_capacity
  min_size            = var.min_capacity
  max_size            = var.max_capacity
  vpc_zone_identifier = var.subnet_ids

  health_check_grace_period = 300 # Wait 5 minutes before checking health
  default_instance_warmup   = 300 # Wait 5 minutes before adding to LB for recieving traffic

  launch_template {
    id      = aws_launch_template.lt.id
    version = aws_launch_template.lt.latest_version
  }

  target_group_arns = var.target_group_arns

  lifecycle {
    create_before_destroy = true
  }
  instance_refresh {
    strategy = "Rolling"
  }
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.app_name}-${var.environment}-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.app_name}-${var.environment}-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg.name
}
