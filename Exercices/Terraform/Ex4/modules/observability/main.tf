resource "random_string" "suffix" {
  length  = 5
  upper   = false
  lower   = true
  numeric = true
  special = false
}

locals {
  storage_account_name         = substr(lower(replace("stex4flow${random_string.suffix.result}", "-", "")), 0, 24)
  default_network_watcher_name = "NetworkWatcher_${replace(lower(var.location), " ", "")}"
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = var.log_analytics_workspace_name
  location            = var.location
  resource_group_name = var.rg_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_analytics_retention_days
  tags                = var.tags
}

resource "azurerm_storage_account" "flowlogs" {
  name                     = local.storage_account_name
  resource_group_name      = var.rg_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  tags                     = var.tags
}

data "azurerm_network_watcher" "regional" {
  name                = var.network_watcher_name != null && var.network_watcher_name != "" ? var.network_watcher_name : local.default_network_watcher_name
  resource_group_name = var.network_watcher_resource_group_name
}

resource "azurerm_network_watcher_flow_log" "vnet" {
  name                 = "${var.log_analytics_workspace_name}-vnet-flowlog"
  network_watcher_name = data.azurerm_network_watcher.regional.name
  resource_group_name  = data.azurerm_network_watcher.regional.resource_group_name

  target_resource_id = var.vnet_id
  storage_account_id = azurerm_storage_account.flowlogs.id
  enabled            = true
  version            = 2

  retention_policy {
    enabled = true
    days    = var.flow_log_retention_days
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = azurerm_log_analytics_workspace.main.workspace_id
    workspace_region      = azurerm_log_analytics_workspace.main.location
    workspace_resource_id = azurerm_log_analytics_workspace.main.id
    interval_in_minutes   = 10
  }
}

resource "azurerm_virtual_machine_extension" "ama_front" {
  name                       = "AzureMonitorLinuxAgent"
  virtual_machine_id         = var.vm_front_id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
}

resource "azurerm_virtual_machine_extension" "ama_back" {
  name                       = "AzureMonitorLinuxAgent"
  virtual_machine_id         = var.vm_back_id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
}

resource "azurerm_monitor_data_collection_rule" "syslog" {
  name                = "${var.log_analytics_workspace_name}-syslog-dcr"
  resource_group_name = var.rg_name
  location            = var.location
  tags                = var.tags

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.main.id
      name                  = "law-destination"
    }
  }

  data_flow {
    streams      = ["Microsoft-Syslog"]
    destinations = ["law-destination"]
  }

  data_sources {
    syslog {
      name           = "syslog-all"
      facility_names = ["*"]
      log_levels     = ["*"]
      streams        = ["Microsoft-Syslog"]
    }
  }
}

resource "azurerm_monitor_data_collection_rule_association" "vm_front" {
  name                    = "dcr-assoc-vm-front"
  target_resource_id      = var.vm_front_id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.syslog.id

  depends_on = [azurerm_virtual_machine_extension.ama_front]
}

resource "azurerm_monitor_data_collection_rule_association" "vm_back" {
  name                    = "dcr-assoc-vm-back"
  target_resource_id      = var.vm_back_id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.syslog.id

  depends_on = [azurerm_virtual_machine_extension.ama_back]
}
