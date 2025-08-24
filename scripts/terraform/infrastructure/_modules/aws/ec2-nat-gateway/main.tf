# Get subnet info for AZ
data "aws_subnet" "nat_subnet" {
  id = var.subnet_id
}

# Network Interface for NAT instance
resource "aws_network_interface" "nat_eni" {
  subnet_id         = var.subnet_id
  private_ips       = var.eni_private_ip != null ? [var.eni_private_ip] : null
  security_groups   = var.security_group_ids
  source_dest_check = false

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-eni"
  })
}

# EIP for NAT instance
resource "aws_eip" "nat_eip" {
  count = var.eip_allocation_id == null ? 1 : 0

  network_interface = aws_network_interface.nat_eni.id
  domain            = "vpc"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-eip"
  })
}

# EIP Association for existing EIP
resource "aws_eip_association" "nat_eip_assoc" {
  count                = var.eip_allocation_id != null ? 1 : 0
  allocation_id        = var.eip_allocation_id
  network_interface_id = aws_network_interface.nat_eni.id
}

# IAM Role for NAT instance
resource "aws_iam_role" "nat_instance_role" {
  name = "${var.name_prefix}-nat-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.nat_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "nat_instance_profile" {
  name = "${var.name_prefix}-nat-instance-profile"
  role = aws_iam_role.nat_instance_role.name
}

# Launch Template for NAT instance
resource "aws_launch_template" "nat_lt" {
  name_prefix   = "${var.name_prefix}-nat-"
  image_id      = var.nat_ami
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.nat_instance_profile.name
  }

  network_interfaces {
    network_interface_id = aws_network_interface.nat_eni.id
    device_index         = 0
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "${var.name_prefix}-nat-instance"
    })
  }

  user_data = base64encode(<<-EOT
    #!/bin/bash
    yum update -y
    yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent

    # Enable IP forwarding
    echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
    sysctl -p

    # Configure NAT
    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    iptables -A FORWARD -i eth0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -i eth0 -o eth0 -j ACCEPT

    # Save iptables rules
    service iptables save
    EOT
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "nat_asg" {
  name                = "${var.name_prefix}-nat-asg"
  desired_capacity    = var.asg_desired_capacity
  max_size            = var.asg_max_size
  min_size            = var.asg_min_size
  availability_zones  = [data.aws_subnet.nat_subnet.availability_zone]

  launch_template {
    id      = aws_launch_template.nat_lt.id
    version = aws_launch_template.nat_lt.latest_version
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300

  instance_refresh {
    strategy = "Rolling"
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-nat-instance"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}