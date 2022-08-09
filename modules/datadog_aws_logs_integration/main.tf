module "setup_datadog" {
  source = "../datadog_base_module"
  datadog_api_key = var.datadog_api_key 
  datadog_app_key = var.datadog_app_key

}

module "aws_integration" {
  source = "../datadog_aws_metrics_integration"  
  account_id = var.aws_account_id
  datadog_team_name = var.datadog_team_name
}
# Creates a lambda function which will be used to forward logs from AWS to Datadog
resource "aws_cloudformation_stack" "datadog_forwarder" {
  name         = "datadog-forwarder"
  capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND"]
  parameters   = {
    DdApiKeySecretArn  = module.secret_keys.dd_api_key_arn,
    DdSite             = "datadoghq.com",
    FunctionName       = "datadog-forwarder"
  }
  template_url = "https://datadog-cloudformation-template.s3.amazonaws.com/aws/forwarder/latest.yaml"
}

resource "datadog_integration_aws_lambda_arn" "main_collector" {
  account_id = var.aws_account_id
  lambda_arn = aws_cloudformation_stack.datadog_forwarder.outputs.DatadogForwarderArn
}

resource "aws_cloudwatch_log_subscription_filter" "datadog_log_subscription_filter" {
  name            = "datadog_log_subscription_filter"
  log_group_name  = var.cloudwatch_log_groups # for example, /aws/lambda/my_lambda_name
  destination_arn = aws_cloudformation_stack.datadog_forwarder.outputs.DatadogForwarderArn # for example,  arn:aws:lambda:us-east-1:123:function:datadog-forwarder
  filter_pattern  = ""
}

resource "datadog_integration_aws_log_collection" "main" {
  account_id = var.aws_account_id
  services   = ["s3"]
  depends_on = [datadog_integration_aws_lambda_arn.main_collector]
}

# This can be uncommented if you do want Datadog to auto configure collection of all s3 audit logs.
// resource "aws_s3_bucket_notification" "s3_bucket_notification" {
//   bucket = var.bucket_name
//   lambda_function {
//     lambda_function_arn = aws_cloudformation_stack.datadog_forwarder.outputs.DatadogForwarderArn
//     events              = ["s3:ObjectCreated:*"]
//    filter_prefix       = "AWSLogs/"
//     filter_suffix       = ".log"
//   }
// }