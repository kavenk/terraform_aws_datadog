provider "aws" {
  alias = "target-account"
}

provider "datadog" {}

variable "datadog_team_name" {
  description = "team name to tag all resources with that are monitored by Datadog"
}

