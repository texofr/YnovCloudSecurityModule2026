resource "azurerm_log_analytics_workspace" "main" {
  name                       = var.log_analytics_workspace_name
  location                   = var.location
  resource_group_name        = var.rg_name
  sku                        = "PerGB2018"
  retention_in_days          = var.log_analytics_retention_days
  internet_ingestion_enabled = false
  internet_query_enabled     = false
  tags                       = var.tags
}

resource "azurerm_monitor_private_link_scope" "main" {
  name                = "${var.log_analytics_workspace_name}-ampls"
  resource_group_name = var.rg_name
  tags                = var.tags
}

resource "azurerm_monitor_private_link_scoped_service" "law" {
  name                = "${var.log_analytics_workspace_name}-scoped"
  resource_group_name = var.rg_name
  scope_name          = azurerm_monitor_private_link_scope.main.name
  linked_resource_id  = azurerm_log_analytics_workspace.main.id
}

resource "azurerm_private_dns_zone" "monitor" {
  name                = "privatelink.monitor.azure.com"
  resource_group_name = var.rg_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone" "oms" {
  name                = "privatelink.oms.opinsights.azure.com"
  resource_group_name = var.rg_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone" "ods" {
  name                = "privatelink.ods.opinsights.azure.com"
  resource_group_name = var.rg_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone" "agentsvc" {
  name                = "privatelink.agentsvc.azure-automation.net"
  resource_group_name = var.rg_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "monitor" {
  name                  = "monitor-zone-link"
  resource_group_name   = var.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.monitor.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
  tags                  = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "oms" {
  name                  = "oms-zone-link"
  resource_group_name   = var.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.oms.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
  tags                  = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "ods" {
  name                  = "ods-zone-link"
  resource_group_name   = var.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.ods.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
  tags                  = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "agentsvc" {
  name                  = "agentsvc-zone-link"
  resource_group_name   = var.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.agentsvc.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
  tags                  = var.tags
}

resource "azurerm_private_endpoint" "ampls" {
  name                = "${var.log_analytics_workspace_name}-ampls-pe"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "${var.log_analytics_workspace_name}-ampls-psc"
    private_connection_resource_id = azurerm_monitor_private_link_scope.main.id
    is_manual_connection           = false
    subresource_names              = ["azuremonitor"]
  }

  private_dns_zone_group {
    name = "ampls-dns-zone-group"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.monitor.id,
      azurerm_private_dns_zone.oms.id,
      azurerm_private_dns_zone.ods.id,
      azurerm_private_dns_zone.agentsvc.id
    ]
  }
}

data "azurerm_monitor_diagnostic_categories" "sql_server" {
  resource_id = var.sql_server_id
}

resource "azurerm_monitor_diagnostic_setting" "sql_server" {
  name                       = "diag-sql-server"
  target_resource_id         = var.sql_server_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  dynamic "enabled_log" {
    for_each = toset(data.azurerm_monitor_diagnostic_categories.sql_server.log_category_types)
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = toset(data.azurerm_monitor_diagnostic_categories.sql_server.metrics)
    content {
      category = metric.value
      enabled  = true
    }
  }
}

data "azurerm_monitor_diagnostic_categories" "sql_database" {
  resource_id = var.sql_database_id
}

resource "azurerm_monitor_diagnostic_setting" "sql_database" {
  name                       = "diag-sql-db"
  target_resource_id         = var.sql_database_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  dynamic "enabled_log" {
    for_each = toset(data.azurerm_monitor_diagnostic_categories.sql_database.log_category_types)
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = toset(data.azurerm_monitor_diagnostic_categories.sql_database.metrics)
    content {
      category = metric.value
      enabled  = true
    }
  }
}

data "azurerm_monitor_diagnostic_categories" "vm" {
  resource_id = var.vm_id
}

resource "azurerm_monitor_diagnostic_setting" "vm" {
  name                       = "diag-vm"
  target_resource_id         = var.vm_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  dynamic "enabled_log" {
    for_each = toset(data.azurerm_monitor_diagnostic_categories.vm.log_category_types)
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = toset(data.azurerm_monitor_diagnostic_categories.vm.metrics)
    content {
      category = metric.value
      enabled  = true
    }
  }
}

data "azurerm_monitor_diagnostic_categories" "nsg" {
  resource_id = var.nsg_id
}

resource "azurerm_monitor_diagnostic_setting" "nsg" {
  name                       = "diag-nsg"
  target_resource_id         = var.nsg_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  dynamic "enabled_log" {
    for_each = toset(data.azurerm_monitor_diagnostic_categories.nsg.log_category_types)
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = toset(data.azurerm_monitor_diagnostic_categories.nsg.metrics)
    content {
      category = metric.value
      enabled  = true
    }
  }
}

# Note: Private Endpoints do not support diagnostic settings in Azure Monitor.
# The sql_private_endpoint is not included in diagnostics configuration.
