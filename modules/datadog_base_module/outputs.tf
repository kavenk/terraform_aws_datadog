output "dd_api_key_arn" {
  value = aws_secretsmanager_secret.dd_api_key.arn
}

output "dd_app_key_arn" {
  value = aws_secretsmanager_secret.dd_app_key.arn
}
output "dd_api_key"{
  value = var.datadog_api_key
}

output "dd_app_key" {
  value = var.datadog_app_key
}