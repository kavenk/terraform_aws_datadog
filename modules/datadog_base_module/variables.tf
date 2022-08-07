variable "datadog_api_key" {
  type        = string
  description = "Datadog application key for your team"
  nullable = false
}

variable "datadog_app_key" {
  type = string
  description = "Datadog app key for your application."
  nullable = false
}
