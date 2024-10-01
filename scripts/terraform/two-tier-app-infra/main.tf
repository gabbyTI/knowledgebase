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

# Elastic Load Balancer (if not already defined)
resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]
}

# Target Group for Load Balancer
resource "aws_lb_target_group" "app_lb_tg" {
  name     = "app-lb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    interval            = 30
    path                = "/"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Load Balancer Listener 
resource "aws_lb_listener" "app_lb_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_lb_tg.arn
  }
}

#####################################################
# DB
####################################################

# RDS Instance
resource "aws_db_instance" "app_db" {
  allocated_storage      = 20
  engine                 = "mysql"
  instance_class         = "db.c6gd.medium"
  db_name                = "mydb"
  username               = var.db_username
  password               = var.db_password
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.main.id
  skip_final_snapshot    = true
  storage_encrypted      = true
  kms_key_id             = aws_kms_key.rds_key.arn
}

# RDS Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "main-subnet-group"
  subnet_ids = [for subnet in aws_subnet.private : subnet.id]
}

# KMS Key for DB encryption at rest
resource "aws_kms_key" "rds_key" {
  description = "KMS key for RDS encryption"
}
