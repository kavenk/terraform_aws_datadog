# Sets up integration in Datadog
resource "datadog_integration_aws" "datadog_integration" {
  account_id  = var.aws_account_id
  role_name   = "DatadogAWSIntegrationRole"
  host_tags   = ["team:${var.datadog_team_name}"]
  filter_tags = ["datadog:true"] # this restricts host monitoring to only hosts with "datadog:true" tag, please don't remove this
  excluded_regions = ["eu-west-1", "eu-west-2", "ap-southeast-1", "ap-southeast-2", "ap-southeast-3"]
}
 
# Creates a lamda function which will be used to forward logs from AWS to Datadog
resource "aws_cloudformation_stack" "datadog_forwarder" {
  name         = "datadog-forwarder"
  capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND"]
  parameters = {
    DdApiKeySecretArn = aws_secretsmanager_secret.datadog_api_key.arn
    DdSite            = "datadoghq.com",
    FunctionName      = "datadog-forwarder"
  }
  template_url = "https://datadog-cloudformation-template.s3.amazonaws.com/aws/forwarder/latest.yaml"
}
 
resource "datadog_integration_aws_lambda_arn" "main_collector" {
  account_id = var.aws_account_id
  lambda_arn = aws_cloudformation_stack.datadog_forwarder.outputs.DatadogForwarderArn
}
 
# This can be uncommented if you want Datadog to auto configure collection of all s3 audit logs.
// resource "datadog_integration_aws_log_collection" "main" {
//   account_id = var.aws_account_id
//   services   = ["s3"]
//   depends_on = [datadog_integration_aws_lambda_arn.main_collector]
// }
 
# This limits lambda monitoring to only lambdas with tag "datadog:true", please do not remove
resource "datadog_integration_aws_tag_filter" "lambda_filter" {
  account_id     = var.aws_account_id
  namespace      = "lambda"
  tag_filter_str = "datadog:true"
}

# IAM
data "aws_iam_policy_document" "datadog_aws_integration_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
 
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::464622532012:root"]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
 
      values = [ datadog_integration_aws.sandbox.external_id]
    }
  }
}
 
data "aws_iam_policy_document" "datadog_aws_integration" {
  statement {
    actions = [
      "apigateway:GET",
      "autoscaling:Describe*",
      "budgets:ViewBudget",
      "cloudfront:GetDistributionConfig",
      "cloudfront:ListDistributions",
      "cloudtrail:DescribeTrails",
      "cloudtrail:GetTrailStatus",
      "cloudtrail:LookupEvents",
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*",
      "codedeploy:List*",
      "codedeploy:BatchGet*",
      "directconnect:Describe*",
      "dynamodb:List*",
      "dynamodb:Describe*",
      "ec2:Describe*",
      "ecs:Describe*",
      "ecs:List*",
      "elasticache:Describe*",
      "elasticache:List*",
      "elasticfilesystem:DescribeFileSystems",
      "elasticfilesystem:DescribeTags",
      "elasticfilesystem:DescribeAccessPoints",
      "elasticloadbalancing:Describe*",
      "elasticmapreduce:List*",
      "elasticmapreduce:Describe*",
      "es:ListTags",
      "es:ListDomainNames",
      "es:DescribeElasticsearchDomains",
      "events:CreateEventBus",
      "fsx:DescribeFileSystems",
      "fsx:ListTagsForResource",
      "health:DescribeEvents",
      "health:DescribeEventDetails",
      "health:DescribeAffectedEntities",
      "kinesis:List*",
      "kinesis:Describe*",
      "lambda:GetPolicy",
      "lambda:List*",
      "logs:DeleteSubscriptionFilter",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:DescribeSubscriptionFilters",
      "logs:FilterLogEvents",
      "logs:PutSubscriptionFilter",
      "logs:TestMetricFilter",
      "organizations:DescribeOrganization",
      "rds:Describe*",
      "rds:List*",
      "redshift:DescribeClusters",
      "redshift:DescribeLoggingStatus",
      "route53:List*",
      "s3:GetBucketLogging",
      "s3:GetBucketLocation",
      "s3:GetBucketNotification",
      "s3:GetBucketTagging",
      "s3:ListAllMyBuckets",
      "s3:PutBucketNotification",
      "ses:Get*",
      "sns:List*",
      "sns:Publish",
      "sqs:ListQueues",
      "states:ListStateMachines",
      "states:DescribeStateMachine",
      "support:*",
      "tag:GetResources",
      "tag:GetTagKeys",
      "tag:GetTagValues",
      "xray:BatchGetTraces",
      "xray:GetTraceSummaries"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}
 
resource "aws_iam_policy" "datadog_aws_integration" {
  name   = "DatadogAWSIntegrationPolicy"
  provider      = aws.target-account
  policy = data.aws_iam_policy_document.datadog_aws_integration.json
}
 
resource "aws_iam_role" "datadog_aws_integration" {
  name               = "DatadogAWSIntegrationRole"
  provider      = aws.target-account
  description        = "Role for Datadog AWS Integration"
  assume_role_policy = data.aws_iam_policy_document.datadog_aws_integration_assume_role.json
}
 
resource "aws_iam_role_policy_attachment" "datadog_aws_integration" {
  role       = aws_iam_role.datadog_aws_integration.name
  provider      = aws.target-account
  policy_arn = aws_iam_policy.datadog_aws_integration.arn
}
 
resource "aws_secretsmanager_secret" "datadog_api_key" {
  name        = "datadog_api_key"
  provider      = aws.target-account
  description = "Encrypted Datadog API Key"
}
 
resource "aws_secretsmanager_secret_version" "dd_api_key" {
  secret_id     = aws_secretsmanager_secret.datadog_api_key.id
  provider      = aws.target-account
  secret_string = var.datadog_api_key
}

