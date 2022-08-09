
module "secret_keys" {
  source = "../datadog_base_module"
  datadog_api_key = var.datadog_api_key 
  datadog_app_key = var.datadog_app_key

}

# Configures metrics integration in Datadog
resource "datadog_integration_aws" "aws_instance" {
  account_id  = var.aws_account_id
  role_name   = "DatadogAWSIntegrationRole"
  host_tags   = ["team:${var.datadog_team_name}"]
  filter_tags = ["datadog:true"] # only hosts with 'datadog:true' tag will be added ..Dont remove this line !!! 
  excluded_regions = ["eu-east-1", "eu-west-2"]
}

module "iam_policies" {
  source = "../datadog_aws_iam"
  external_id = datadog_integration_aws.aws_instance.external_id

}
 
# Uncomment this if you want services to be monitored by datadog (service_name can be lambda,sqs,sns etc)
// resource "datadog_integration_aws_tag_filter" "service_name_filter" {
//   account_id     = var.aws_account_id
//   namespace      = "service_name" # set service name for example: lambda
//   tag_filter_str = "datadog:true"
// }

# IAM assume sts role
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
 
      values = [ datadog_integration_aws.aws_instance.external_id ]
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
  name      = "DatadogAWSIntegrationPolicy"
  provider  = aws.target-account
  policy    = data.aws_iam_policy_document.datadog_aws_integration.json
}
 
resource "aws_iam_role" "datadog_aws_integration" {
  name               = "DatadogAWSIntegrationRole"
  provider           = aws.target-account
  description        = "Role for Datadog AWS Integration"
  assume_role_policy = data.aws_iam_policy_document.datadog_aws_integration_assume_role.json
}
 
resource "aws_iam_role_policy_attachment" "datadog_aws_integration" {
  role       = aws_iam_role.datadog_aws_integration.name
  provider   = aws.target-account
  policy_arn = aws_iam_policy.datadog_aws_integration.arn
}
 


