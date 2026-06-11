output "resource_group_name" {
  description = "Resource group used for deployment"
  value       = data.azurerm_resource_group.rg.name
}

output "acr_id" {
  description = "Azure Container Registry resource ID"
  value       = module.registry.acr_id
}

output "acr_name" {
  description = "Azure Container Registry name"
  value       = module.registry.acr_name
}

output "acr_login_server" {
  description = "ACR login server"
  value       = module.registry.acr_login_server
}

output "docker_image_name" {
  description = "Docker repository name used in ACR"
  value       = var.docker_image_name
}

output "web_app_id" {
  description = "Linux Web App resource ID"
  value       = module.webapp.web_app_id
}

output "web_app_name" {
  description = "Linux Web App name"
  value       = module.webapp.web_app_name
}

output "web_app_default_hostname" {
  description = "Web App default hostname"
  value       = module.webapp.web_app_default_hostname
}
