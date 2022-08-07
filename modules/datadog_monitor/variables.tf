variable "datadog_api_key" {
  type        = string
  description = "Datadog API Key"
}

variable "datadog_app_key" {
  type        = string
  description = "Datadog Application Key "
}

variable "monitor_type" {
  type        = string
  default     = "metric alert"
  description = "Type of the monitor for example - metric alert"
}

variable "monitor_name" {
  type        = string
  description = "Monitor name which you create on datadog"
}

variable "monitor_message" {
  type        = string
  description = "Monitor description (what are you trying to monitor)"
}

variable "tags" {
  type        = list(string)
  description = "Include team name and owner name"
}

variable "query" {
  type        = string
  default     = "avg(last_1m):avg:system.cpu.system{*} by {host} > 60"
  description = "Include queery for the monitor."
}
