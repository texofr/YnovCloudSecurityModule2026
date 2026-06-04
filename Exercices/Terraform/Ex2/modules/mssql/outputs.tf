output "sql_server_name" {
  value = azurerm_mssql_server.sql_server.name
}

output "sql_server_fqdn" {
  value = azurerm_mssql_server.sql_server.fully_qualified_domain_name
}

output "sql_database_name" {
  value = azurerm_mssql_database.sql_database.name
}

output "private_endpoint_ip" {
  value = azurerm_private_endpoint.sql_private_endpoint.private_service_connection[0].private_ip_address
}

output "generated_sql_admin_password" {
  value     = random_password.generated_sql_admin_password.result
  sensitive = true
}

output "sql_server_id" {
  value = azurerm_mssql_server.sql_server.id
}

output "sql_database_id" {
  value = azurerm_mssql_database.sql_database.id
}

output "sql_private_endpoint_id" {
  value = azurerm_private_endpoint.sql_private_endpoint.id
}
