resource "random_password" "generated_sql_admin_password" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

locals {
  effective_sql_admin_password = coalesce(var.sql_admin_password, random_password.generated_sql_admin_password.result)
}

resource "azurerm_mssql_server" "sql_server" {
  name                          = var.sql_server_name
  resource_group_name           = var.rg_name
  location                      = var.location
  version                       = "12.0"
  administrator_login           = var.sql_admin_login
  administrator_login_password  = local.effective_sql_admin_password
  minimum_tls_version           = "1.2"
  public_network_access_enabled = false
  tags                          = var.tags

  identity {
    type = "SystemAssigned"
  }

  azuread_administrator {
    login_username              = var.aad_admin_login_username
    object_id                   = var.aad_admin_object_id
    azuread_authentication_only = true
  }
}

resource "azurerm_mssql_database" "sql_database" {
  name                                = var.sql_database_name
  server_id                           = azurerm_mssql_server.sql_server.id
  sku_name                            = "Basic"
  max_size_gb                         = 2
  collation                           = "SQL_Latin1_General_CP1_CI_AS"
  transparent_data_encryption_enabled = true
  tags                                = var.tags

  short_term_retention_policy {
    retention_days = 7
  }
}

resource "azurerm_private_dns_zone" "sql_private_dns" {
  name                = "privatelink.database.windows.net"
  resource_group_name = var.rg_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql_private_dns_link" {
  name                  = "${var.sql_server_name}-dnslink"
  resource_group_name   = var.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.sql_private_dns.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
  tags                  = var.tags
}

resource "azurerm_private_endpoint" "sql_private_endpoint" {
  name                = "${var.sql_server_name}-pe"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.target_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "${var.sql_server_name}-psc"
    private_connection_resource_id = azurerm_mssql_server.sql_server.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }

  private_dns_zone_group {
    name                 = "sql-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.sql_private_dns.id]
  }
}
