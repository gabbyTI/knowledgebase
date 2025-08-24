locals {
  db_password = var.db_password != null ? var.db_password : random_password.postgres_password[0].result
}