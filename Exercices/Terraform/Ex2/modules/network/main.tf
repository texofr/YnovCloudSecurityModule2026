resource "azurerm_network_security_group" "db_nsg" {
  name                = "${var.vnet_name}-db-nsg"
  location            = var.location
  resource_group_name = var.rg_name
  tags                = var.tags

  # Default NSG rules already deny inbound Internet traffic.
  # This explicit rule is educational to make the intent visible.
  security_rule {
    name                       = "deny-internet-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = [var.vnet_cidr]
  location            = var.location
  resource_group_name = var.rg_name
  tags                = var.tags
}

# Subnet where application workloads will live.
resource "azurerm_subnet" "db_subnet" {
  name                 = "db-workload-subnet"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.db_subnet_cidr]
}

resource "azurerm_subnet_network_security_group_association" "db_subnet_assoc" {
  subnet_id                 = azurerm_subnet.db_subnet.id
  network_security_group_id = azurerm_network_security_group.db_nsg.id
}

# Dedicated subnet for Private Endpoints.
resource "azurerm_subnet" "private_endpoint_subnet" {
  name                 = "private-endpoints-subnet"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.private_endpoint_subnet_cidr]

  private_endpoint_network_policies = "Disabled"
}

# Azure Bastion subnet (required name: AzureBastionSubnet).
resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.bastion_subnet_cidr]
}

# Public IP for Azure Bastion.
resource "azurerm_public_ip" "bastion_pip" {
  name                = "${var.vnet_name}-bastion-pip"
  location            = var.location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# Azure Bastion Host for VM access without public IPs.
resource "azurerm_bastion_host" "main" {
  name                = "${var.vnet_name}-bastion"
  location            = var.location
  resource_group_name = var.rg_name
  tags                = var.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }
}
