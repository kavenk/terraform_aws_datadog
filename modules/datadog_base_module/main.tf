resource "aws_secretsmanager_secret" "dd_api_key" {
  name        = "datadog_api_key"
  description = "Encrypted Datadog API Key"
}

resource "aws_secretsmanager_secret_version" "dd_api_key" {
  secret_id     = aws_secretsmanager_secret.dd_api_key.id
  secret_string = var.datadog_api_key
}

resource "aws_secretsmanager_secret" "dd_app_key" {
  name        = "datadog_app_key"
  description = "Encrypted Datadog application Key"
}

resource "aws_secretsmanager_secret_version" "dd_app_key" {
  secret_id     = aws_secretsmanager_secret.dd_app_key.id
  secret_string = var.datadog_app_key
}