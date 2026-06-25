output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.main.id
}

output "log_analytics_workspace_name" {
  value = azurerm_log_analytics_workspace.main.name
}

output "flow_log_name" {
  value = azurerm_network_watcher_flow_log.vnet.name
}

output "dcr_id" {
  value = azurerm_monitor_data_collection_rule.syslog.id
}
