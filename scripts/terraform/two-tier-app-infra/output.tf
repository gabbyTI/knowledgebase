output "lb_url" {
  value = "http://${aws_lb.app_lb.dns_name}"
}
output "db_endpoint" {
  value = aws_db_instance.app_db.endpoint
}
output "db_username" {
  value = aws_db_instance.app_db.username
}
output "db_password" {
  value     = aws_db_instance.app_db.password
  sensitive = true
}
output "db_name" {
  value = aws_db_instance.app_db.db_name
}