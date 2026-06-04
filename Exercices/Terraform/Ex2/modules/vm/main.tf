resource "random_password" "vm_admin_password" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_network_interface" "sql_client_nic" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = var.rg_name
  tags                = var.tags

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "sql_client" {
  name                            = var.vm_name
  resource_group_name             = var.rg_name
  location                        = var.location
  size                            = var.vm_size
  admin_username                  = var.admin_username
  admin_password                  = random_password.vm_admin_password.result
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.sql_client_nic.id]
  tags                            = var.tags

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Important: VM size (e.g., Standard_D2als_v6, v5, v6) may require Gen2 image.
  # Gen1 sizes use "22_04-lts", Gen2 sizes use "22_04-lts-gen2".
  # Mismatch between VM size and image hypervisor generation will cause 400 BadRequest errors.
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  custom_data = base64encode(<<-CLOUDINIT
    #cloud-config
    package_update: true
    package_upgrade: false
    packages:
      - ca-certificates
      - curl
      - gnupg
      - lsb-release
      - unixodbc
      - apt-transport-https

    write_files:
      - path: /usr/local/bin/sql-mi-connect-example.sh
        permissions: "0755"
        content: |
          #!/usr/bin/env bash
          set -euo pipefail
          az login --identity >/dev/null
          echo "Managed identity connected."
          echo "SQL Server FQDN: ${var.sql_server_fqdn}.database.windows.net"
          echo "Database: ${var.sql_database_name}"
          echo "Use sqlcmd from /opt/mssql-tools18/bin with Entra auth options available in your environment."

    runcmd:
      - curl -sL https://aka.ms/InstallAzureCLIDeb | bash
      - curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /usr/share/keyrings/microsoft-prod.gpg
      - echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-prod.gpg] https://packages.microsoft.com/ubuntu/22.04/prod jammy main" > /etc/apt/sources.list.d/mssql-release.list
      - apt-get update
      - ACCEPT_EULA=Y apt-get install -y msodbcsql18 mssql-tools18
      - echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> /etc/profile
      - chmod +x /usr/local/bin/sql-mi-connect-example.sh
  CLOUDINIT
  )
}
