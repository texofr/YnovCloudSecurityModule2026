terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "rg" {
  name = var.rg_name
}

module "network" {
  source   = "./modules/network"
  rg_name  = data.azurerm_resource_group.rg.name
  location = data.azurerm_resource_group.rg.location

  vnet_name               = var.vnet_name
  vnet_cidr               = var.vnet_cidr
  frontend_subnet_name    = var.frontend_subnet_name
  frontend_subnet_cidr    = var.frontend_subnet_cidr
  backend_subnet_name     = var.backend_subnet_name
  backend_subnet_cidr     = var.backend_subnet_cidr
  frontend_nsg_name       = var.frontend_nsg_name
  frontend_open_rule_name = var.frontend_open_rule_name

  tags = var.tags
}

module "compute" {
  source   = "./modules/compute"
  rg_name  = data.azurerm_resource_group.rg.name
  location = data.azurerm_resource_group.rg.location

  vm_front_name       = var.vm_front_name
  vm_back_name        = var.vm_back_name
  vm_size             = var.vm_size
  admin_username      = var.vm_admin_username
  frontend_subnet_id  = module.network.frontend_subnet_id
  backend_subnet_id   = module.network.backend_subnet_id
  backend_subnet_cidr = module.network.backend_subnet_cidr

  tags = var.tags
}

module "observability" {
  source   = "./modules/observability"
  rg_name  = data.azurerm_resource_group.rg.name
  location = data.azurerm_resource_group.rg.location

  log_analytics_workspace_name        = var.log_analytics_workspace_name
  log_analytics_retention_days        = var.log_analytics_retention_days
  flow_log_retention_days             = var.flow_log_retention_days
  network_watcher_resource_group_name = var.network_watcher_resource_group_name
  network_watcher_name                = var.network_watcher_name
  vm_front_id                         = module.compute.vm_front_id
  vm_back_id                          = module.compute.vm_back_id
  frontend_nsg_id                     = module.network.frontend_nsg_id

  tags = var.tags
}
