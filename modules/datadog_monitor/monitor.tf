resource "datadog_monitor" "cpumonitor" {
  name = var.monitor_name
  type = var.monitor_type
  message = var.monitor_message
  tags = var.tags
  query = "avg(last_1m):avg:system.cpu.system{*} by {host} > 60"
}


  