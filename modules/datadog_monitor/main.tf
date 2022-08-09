module "setup_datadog" {
  source = "../datadog_base_module"
  datadog_api_key = var.datadog_api_key 
  datadog_app_key = var.datadog_app_key

}
resource "datadog_monitor" "cpumonitor" {
  name = var.monitor_name
  type = var.monitor_type
  message = var.monitor_message
  tags = var.tags
  query = "avg(last_1m):avg:system.cpu.system{*} by {host} > 60"
}