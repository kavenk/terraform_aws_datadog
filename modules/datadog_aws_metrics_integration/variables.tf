provider "aws" {
  alias = "target-account"
}

variable "datadog_api_key" {
  type        = string
  description = "Datadog application key for your team"
}

variable "datadog_app_key" {
  type = string
  description = "Datadog app key for your application."
}

variable "aws_account_id"{
  type        = string
  description = "AWS account ID."
}

variable "datadog_team_name" {
  type        = string
  description = "Team tag in datadog for monitoring resources. "
}

