output "jenkins_server_ip" {
  value = aws_instance.primary.public_ip
}
output "jenkins_slave1_ip" {
  value = aws_instance.slave1.public_ip
}