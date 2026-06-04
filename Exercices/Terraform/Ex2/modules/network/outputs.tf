output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "db_subnet_id" {
  value = azurerm_subnet.db_subnet.id
}

output "private_endpoint_subnet_id" {
  value = azurerm_subnet.private_endpoint_subnet.id
}

output "db_nsg_id" {
  value = azurerm_network_security_group.db_nsg.id
}

output "bastion_host_id" {
  value = azurerm_bastion_host.main.id
}

output "bastion_public_ip" {
  value = azurerm_public_ip.bastion_pip.ip_address
}
