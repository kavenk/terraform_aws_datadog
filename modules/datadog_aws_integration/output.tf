output "ddatadog_SM_api_key" {
  value = aws_secretsmanager_secret.datadog_api_key.arn
}

