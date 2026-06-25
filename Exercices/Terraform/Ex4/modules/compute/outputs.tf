output "vm_front_id" {
  value = azurerm_linux_virtual_machine.vm_front.id
}

output "vm_back_id" {
  value = azurerm_linux_virtual_machine.vm_back.id
}

output "vm_front_private_ip" {
  value = azurerm_network_interface.frontend.private_ip_address
}

output "vm_back_private_ip" {
  value = azurerm_network_interface.backend.private_ip_address
}

output "vm_admin_password" {
  value     = random_password.vm_admin_password.result
  sensitive = true
}
