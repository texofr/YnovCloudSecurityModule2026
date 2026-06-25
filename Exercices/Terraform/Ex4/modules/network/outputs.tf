output "vnet_id" {
  value = azurerm_virtual_network.main.id
}

output "frontend_subnet_id" {
  value = azurerm_subnet.frontend.id
}

output "backend_subnet_id" {
  value = azurerm_subnet.backend.id
}

output "backend_subnet_cidr" {
  value = var.backend_subnet_cidr
}

output "frontend_nsg_id" {
  value = azurerm_network_security_group.frontend.id
}
