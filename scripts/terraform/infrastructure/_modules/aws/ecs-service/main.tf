# Task Definition
resource "aws_ecs_task_definition" "this" {
  family                   = var.family
  requires_compatibilities = ["EC2"]
  cpu                      = var.cpu
  memory                   = var.memory
  network_mode             = "bridge"
  task_role_arn           = var.task_role_arn
  execution_role_arn      = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name  = var.container_name
      image = var.image
      cpu   = var.cpu
      memory = var.memory
      
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = 0
          protocol      = "tcp"
        }
      ]
      
      environment = [
        for key, value in var.environment_variables : {
          name  = key
          value = value
        }
      ]
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.family}"
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }
      
      essential = true
    }
  ])

  tags = var.tags
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.family}"
  retention_in_days = 7
  tags              = var.tags
}

# Data source for current region
data "aws_region" "current" {}

# Target Group (optional creation)
resource "aws_lb_target_group" "this" {
  count = var.create_target_group ? 1 : 0

  name     = "${var.service_name}-tg"
  port     = var.target_group_port
  protocol = var.target_group_protocol
  vpc_id   = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = var.health_check_enabled
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    timeout             = var.health_check_timeout
    interval            = var.health_check_interval
    path                = var.health_check_path
    matcher             = "200"
    protocol            = var.target_group_protocol
  }

  depends_on = [ var.listener_arn ]

  tags = merge(var.tags, {
    Name = "${var.service_name}-target-group"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# ECS Service
resource "aws_ecs_service" "this" {
  name            = var.service_name
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count

  # Use capacity provider instead of launch type
  capacity_provider_strategy {
    capacity_provider = var.capacity_provider_name
    weight           = 1
  }

  # Load balancer configuration
  dynamic "load_balancer" {
    for_each = var.create_target_group || var.target_group_arn != null ? [1] : []
    content {
      target_group_arn = var.create_target_group ? aws_lb_target_group.this[0].arn : var.target_group_arn
      container_name   = var.container_name
      container_port   = var.container_port
    }
  }

  # Wait for load balancer to be ready
  depends_on = [aws_lb_target_group.this, aws_cloudwatch_log_group.this]

  tags = var.tags

}

# ALB Listener Rule (optional)
resource "aws_lb_listener_rule" "this" {
  count = var.create_listener_rule ? 1 : 0

  listener_arn = var.listener_arn
  priority     = var.listener_rule_priority

  action {
    type             = "forward"
    target_group_arn = var.create_target_group ? aws_lb_target_group.this[0].arn : var.target_group_arn
  }

  condition {
    path_pattern {
      values = var.path_patterns
    }
  }

  tags = var.tags
}

# Auto Scaling Target (optional)
resource "aws_appautoscaling_target" "this" {
  count = var.enable_autoscaling ? 1 : 0

  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${split("/", var.cluster_arn)[1]}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = [aws_ecs_service.this]

  tags = var.tags
}

# Auto Scaling Policy - CPU Utilization
resource "aws_appautoscaling_policy" "cpu_scaling" {
  count = var.enable_autoscaling ? 1 : 0

  name               = "${var.service_name}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this[0].resource_id
  scalable_dimension = aws_appautoscaling_target.this[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.target_cpu_utilization
    scale_in_cooldown  = var.scale_down_cooldown
    scale_out_cooldown = var.scale_up_cooldown
  }
}