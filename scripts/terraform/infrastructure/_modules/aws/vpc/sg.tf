# Define a Security Group
resource "aws_security_group" "default" {
  name        = "${var.environment}-default-sg"
  description = "Default security group for ${var.environment} VPC"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-default-sg"
  }
}

# Add Ingress and Egress Rules to Security Group
resource "aws_vpc_security_group_ingress_rule" "http_ingress" {
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
  cidr_ipv4 = "0.0.0.0/0"
  security_group_id = aws_security_group.default.id
}

resource "aws_vpc_security_group_ingress_rule" "https_ingress" {
  from_port   = 443
  to_port     = 443
  ip_protocol    = "tcp"
  cidr_ipv4 = "0.0.0.0/0"
  security_group_id = aws_security_group.default.id
}

resource "aws_vpc_security_group_ingress_rule" "ssh_ingress" {
  from_port   = 22
  to_port     = 22
  ip_protocol    = "tcp"
  cidr_ipv4 = "0.0.0.0/0"
  security_group_id = aws_security_group.default.id
}

# Define Egress Rule (default allows all)
resource "aws_vpc_security_group_egress_rule" "default_egress" {
  from_port   = 0
  to_port     = 0
  ip_protocol    = "-1"
  cidr_ipv4 = "0.0.0.0/0"
  security_group_id = aws_security_group.default.id
}