# Generate random password if not provided
resource "random_password" "postgres_password" {
  count   = var.db_password == null ? 1 : 0
  length  = 16
  special = true
}

# Store password in AWS Secrets Manager
resource "aws_secretsmanager_secret" "postgres_credentials" {
  name                    = "${var.name_prefix}-postgres-credentials"
  description             = "PostgreSQL database credentials"
  recovery_window_in_days = 0

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "postgres_credentials" {
  secret_id = aws_secretsmanager_secret.postgres_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = local.db_password
    endpoint = aws_db_instance.postgres.endpoint
    port     = aws_db_instance.postgres.port
    dbname   = aws_db_instance.postgres.db_name
  })
}

# PostgreSQL RDS Instance
resource "aws_db_instance" "postgres" {
  allocated_storage      = var.allocated_storage
  engine                 = "postgres"
  engine_version         = var.postgres_version
  instance_class         = var.instance_class
  db_name                = var.database_name
  username               = var.db_username
  password               = local.db_password
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  skip_final_snapshot    = var.skip_final_snapshot
  storage_encrypted      = true
  kms_key_id             = aws_kms_key.rds_key.arn

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-postgres-instance"
  })
}

# RDS Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.name_prefix}-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = var.tags
}

# Security Group for Database
resource "aws_security_group" "db_sg" {
  name_prefix = "${var.name_prefix}-db-"
  vpc_id      = var.vpc_id
  description = "Security group for PostgreSQL database"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = var.tags
}

# KMS Key for DB encryption at rest
resource "aws_kms_key" "rds_key" {
  description = "KMS key for RDS encryption"

  tags = var.tags
}
