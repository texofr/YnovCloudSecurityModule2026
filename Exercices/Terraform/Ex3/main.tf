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

# Read existing resource group.
data "azurerm_resource_group" "rg" {
  name = var.rg_name
}

resource "random_string" "suffix" {
  length  = 5
  upper   = false
  lower   = true
  numeric = true
  special = false
}

locals {
  acr_name     = substr(lower(replace("${var.acr_name_prefix}${random_string.suffix.result}", "-", "")), 0, 50)
  web_app_name = substr(lower("${var.web_app_name_prefix}-${random_string.suffix.result}"), 0, 60)
}

module "registry" {
  source   = "./modules/acr"
  rg_name  = data.azurerm_resource_group.rg.name
  location = data.azurerm_resource_group.rg.location

  acr_name = local.acr_name
  tags     = var.tags
}

module "webapp" {
  source   = "./modules/webapp"
  rg_name  = data.azurerm_resource_group.rg.name
  location = data.azurerm_resource_group.rg.location

  app_service_plan_name = var.app_service_plan_name
  app_service_plan_sku  = var.app_service_plan_sku
  web_app_name          = local.web_app_name

  acr_id            = module.registry.acr_id
  acr_login_server  = module.registry.acr_login_server
  docker_image_name = var.docker_image_name
  docker_image_tag  = var.docker_image_tag

  tags = var.tags
}
