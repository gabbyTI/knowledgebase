output "endpoint" {
  description = "The PostgreSQL database endpoint"
  value       = aws_db_instance.postgres.endpoint
}

output "port" {
  description = "The PostgreSQL database port"
  value       = aws_db_instance.postgres.port
}

output "database_name" {
  description = "The name of the PostgreSQL database"
  value       = aws_db_instance.postgres.db_name
}

output "username" {
  description = "The PostgreSQL database username"
  value       = aws_db_instance.postgres.username
}

output "security_group_id" {
  description = "The ID of the security group for the PostgreSQL database"
  value       = aws_security_group.db_sg.id
}

output "connection_string" {
  description = "PostgreSQL connection string"
  value       = "postgresql://${aws_db_instance.postgres.username}:${urlencode(local.db_password)}@${aws_db_instance.postgres.endpoint}/${aws_db_instance.postgres.db_name}"
  sensitive   = true
}

output "secrets_manager_secret_id" {
  description = "Secrets Manager secret ID containing database credentials"
  value       = aws_secretsmanager_secret.postgres_credentials.id
}

output "secrets_manager_secret_arn" {
  description = "Secrets Manager secret ARN containing database credentials"
  value       = aws_secretsmanager_secret.postgres_credentials.arn
}