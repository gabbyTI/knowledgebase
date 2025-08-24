resource "tls_private_key" "ssh_key" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "key_pair" {
  key_name_prefix = "${var.name_prefix}-key-pair-"
  public_key      = tls_private_key.ssh_key.public_key_openssh
}

resource "aws_instance" "ec2_instance" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = var.security_group_ids
  subnet_id              = var.subnet_id

  user_data = var.user_data != null ? var.user_data : null

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-instance"
  })

}

resource "aws_eip" "eip" {
  count  = var.create_eip ? 1 : 0
  domain = "vpc"
  tags   = var.tags
}

resource "aws_eip_association" "eip_assoc" {
  count         = var.create_eip ? 1 : 0
  instance_id   = aws_instance.ec2_instance.id
  allocation_id = aws_eip.eip.id
}
