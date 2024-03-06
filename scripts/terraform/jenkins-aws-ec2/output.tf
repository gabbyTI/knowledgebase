output "ec2-instance-ip" {
  value = aws_instance.primary.public_ip
}