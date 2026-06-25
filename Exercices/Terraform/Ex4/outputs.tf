output "resource_group_name" {
  description = "Resource group used for deployment"
  value       = data.azurerm_resource_group.rg.name
}

output "vnet_id" {
  description = "VNet resource ID"
  value       = module.network.vnet_id
}

output "frontend_subnet_id" {
  description = "Frontend subnet ID"
  value       = module.network.frontend_subnet_id
}

output "backend_subnet_id" {
  description = "Backend subnet ID"
  value       = module.network.backend_subnet_id
}

output "frontend_nsg_id" {
  description = "Frontend NSG ID"
  value       = module.network.frontend_nsg_id
}

output "vm_front_private_ip" {
  description = "Private IP of VM-Front"
  value       = module.compute.vm_front_private_ip
}

output "vm_back_private_ip" {
  description = "Private IP of VM-Back"
  value       = module.compute.vm_back_private_ip
}

output "vm_front_id" {
  description = "VM-Front resource ID"
  value       = module.compute.vm_front_id
}

output "vm_back_id" {
  description = "VM-Back resource ID"
  value       = module.compute.vm_back_id
}

output "vm_admin_password" {
  description = "Generated admin password used on both VMs"
  value       = module.compute.vm_admin_password
  sensitive   = true
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  value       = module.observability.log_analytics_workspace_id
}

output "log_analytics_workspace_name" {
  description = "Log Analytics workspace name"
  value       = module.observability.log_analytics_workspace_name
}

output "flow_log_name" {
  description = "Network watcher flow log resource name"
  value       = module.observability.flow_log_name
}

output "dcr_id" {
  description = "Data Collection Rule ID"
  value       = module.observability.dcr_id
}
