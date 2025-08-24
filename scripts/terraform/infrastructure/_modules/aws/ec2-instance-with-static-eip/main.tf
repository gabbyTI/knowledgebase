resource "tls_private_key" "ssh_key" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "key_pair" {
  key_name_prefix = "${var.instance_name}-${var.environment}-key-"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# resource "aws_launch_template" "launch_template" {
#   name_prefix   = "${var.instance_name}-${var.environment}-"
#   image_id      = var.ami
#   instance_type = var.instance_type
#   key_name      = aws_key_pair.key_pair.key_name

#   lifecycle {
#     create_before_destroy = true
#     ignore_changes        = [tag_specifications]
#   }

#   network_interfaces {
#     associate_public_ip_address = true
#     security_groups             = var.security_group_ids
#     delete_on_termination       = true
#   }

#   tag_specifications {
#     resource_type = "instance"

#     tags = var.tags
#   }
# }

# resource "terraform_data" "replacement" {
#   input = aws_launch_template.launch_template.latest_version
# }

resource "aws_instance" "ec2_instance" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = var.security_group_ids

  tags = {
    Name = "${var.instance_name}-${var.environment}-instance"
  }
}

resource "aws_eip" "eip" {
  domain = "vpc"
  tags   = var.tags
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.ec2_instance.id
  allocation_id = aws_eip.eip.id
}
