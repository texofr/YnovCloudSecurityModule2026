output "vm_id" {
  value = azurerm_linux_virtual_machine.sql_client.id
}

output "vm_private_ip" {
  value = azurerm_network_interface.sql_client_nic.private_ip_address
}

output "vm_identity_principal_id" {
  value = azurerm_linux_virtual_machine.sql_client.identity[0].principal_id
}

output "vm_identity_login_name" {
  value = var.vm_name
}

output "vm_admin_password" {
  value     = random_password.vm_admin_password.result
  sensitive = true
}
