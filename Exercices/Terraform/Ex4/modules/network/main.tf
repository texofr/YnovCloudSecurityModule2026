resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.rg_name
  address_space       = [var.vnet_cidr]
  tags                = var.tags
}

resource "azurerm_subnet" "frontend" {
  name                 = var.frontend_subnet_name
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.frontend_subnet_cidr]
}

resource "azurerm_subnet" "backend" {
  name                 = var.backend_subnet_name
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.backend_subnet_cidr]
}

resource "azurerm_network_security_group" "frontend" {
  name                = var.frontend_nsg_name
  location            = var.location
  resource_group_name = var.rg_name
  tags                = var.tags

  # Intentional vulnerability for the lab: expose HTTP from Internet.
  security_rule {
    name                       = var.frontend_open_rule_name
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "frontend_assoc" {
  subnet_id                 = azurerm_subnet.frontend.id
  network_security_group_id = azurerm_network_security_group.frontend.id
}

# Student mission (CTF): create a dedicated Backend NSG and associate it to BackendSubnet.
# Then add a strict inbound deny rule for traffic coming from FrontendSubnet CIDR.
# Example rule idea (not created on purpose here):
# - direction: Inbound
# - access: Deny
# - protocol: *
# - source_address_prefix: FrontendSubnet CIDR
# - destination_address_prefix: BackendSubnet CIDR
