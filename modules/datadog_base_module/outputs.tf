output "dd_api_key_arn" {
  value = aws_secretsmanager_secret.dd_api_key.arn
}

output "dd_api_key"{
  value = var.datadog_api_key
}