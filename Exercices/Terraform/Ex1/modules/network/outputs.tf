output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "db_subnet_id" {
  value = azurerm_subnet.db_subnet.id
}

output "private_endpoint_subnet_id" {
  value = azurerm_subnet.private_endpoint_subnet.id
}
