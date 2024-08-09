output "ec2-instance-ip" {
  value = aws_instance.webserver.public_ip
}