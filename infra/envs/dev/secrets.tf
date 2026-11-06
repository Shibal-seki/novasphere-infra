resource "aws_ssm_parameter" "db_password" {
  name        = "/novasphere/${var.environment}/db_password"
  description = "Secret applicatif NovaSphere"
  type        = "SecureString"
  tier        = "Standard"

  value_wo         = var.db_password
  value_wo_version = 1

  tags = {
    Name        = "novasphere-${var.environment}-secret"
    Environment = var.environment
  }
}
