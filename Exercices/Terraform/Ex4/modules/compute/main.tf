resource "random_password" "vm_admin_password" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_network_interface" "frontend" {
  name                = "${var.vm_front_name}-nic"
  location            = var.location
  resource_group_name = var.rg_name
  tags                = var.tags

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.frontend_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "backend" {
  name                = "${var.vm_back_name}-nic"
  location            = var.location
  resource_group_name = var.rg_name
  tags                = var.tags

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.backend_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm_back" {
  name                            = var.vm_back_name
  resource_group_name             = var.rg_name
  location                        = var.location
  size                            = var.vm_size
  admin_username                  = var.admin_username
  admin_password                  = random_password.vm_admin_password.result
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.backend.id]
  tags                            = var.tags

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  custom_data = base64encode(<<-CLOUDINIT
    #cloud-config
    package_update: true
    runcmd:
      - nohup python3 -m http.server 80 --bind 0.0.0.0 >/var/log/backend-http.log 2>&1 &
  CLOUDINIT
  )
}

resource "azurerm_linux_virtual_machine" "vm_front" {
  name                            = var.vm_front_name
  resource_group_name             = var.rg_name
  location                        = var.location
  size                            = var.vm_size
  admin_username                  = var.admin_username
  admin_password                  = random_password.vm_admin_password.result
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.frontend.id]
  tags                            = var.tags

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # The trap: this startup loop continuously sends HTTP requests to VM-Back.
  custom_data = base64encode(<<-CLOUDINIT
    #cloud-config
    package_update: true
    packages:
      - curl

    write_files:
      - path: /usr/local/bin/flood-backend.sh
        permissions: "0755"
        content: |
          #!/usr/bin/env bash
          while true; do
            curl -s -o /dev/null -m 2 "http://${azurerm_network_interface.backend.private_ip_address}:80/"
            sleep 2
          done

    runcmd:
      - nohup /usr/local/bin/flood-backend.sh >/var/log/flood-backend.log 2>&1 &
  CLOUDINIT
  )
}
