output "sql_server_fqdn" {
  description = "Private SQL server FQDN to use from workloads in the VNet"
  value       = module.ma_base_mssql.sql_server_fqdn
}

output "sql_server_name" {
  description = "SQL logical server name"
  value       = module.ma_base_mssql.sql_server_name
}

output "sql_database_name" {
  description = "Main database name"
  value       = module.ma_base_mssql.sql_database_name
}

output "private_endpoint_ip" {
  description = "Private endpoint IP of the SQL server"
  value       = module.ma_base_mssql.private_endpoint_ip
}

output "generated_sql_admin_password" {
  description = "Only populated when sql_admin_password is null"
  value       = module.ma_base_mssql.generated_sql_admin_password
  sensitive   = true
}
