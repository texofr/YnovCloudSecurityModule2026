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

output "vm_private_ip" {
  description = "Private IP of the Ubuntu SQL client VM"
  value       = module.vm_sql_client.vm_private_ip
}

output "vm_identity_principal_id" {
  description = "System-assigned managed identity principal ID of the VM"
  value       = module.vm_sql_client.vm_identity_principal_id
}

output "log_analytics_workspace_id" {
  description = "Resource ID of the private Log Analytics workspace"
  value       = module.observability.log_analytics_workspace_id
}

output "log_analytics_workspace_name" {
  description = "Name of the private Log Analytics workspace"
  value       = module.observability.log_analytics_workspace_name
}

output "generated_sql_admin_password" {
  description = "Only populated when sql_admin_password is null"
  value       = module.ma_base_mssql.generated_sql_admin_password
  sensitive   = true
}

output "vm_admin_password" {
  description = "Generated local admin password for the Ubuntu VM"
  value       = module.vm_sql_client.vm_admin_password
  sensitive   = true
}

output "bastion_public_ip" {
  description = "Public IP of Azure Bastion for SSH/RDP access to VMs"
  value       = module.mon_reseau.bastion_public_ip
}

output "bastion_host_id" {
  description = "Resource ID of Azure Bastion host"
  value       = module.mon_reseau.bastion_host_id
}
