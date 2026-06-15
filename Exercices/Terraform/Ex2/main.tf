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

  # Example remote backend (optional for students):
  # backend "azurerm" {
  #   resource_group_name  = "RG-TFSTATE"
  #   storage_account_name = "sttfstatelabynovepe"
  #   container_name       = "tfstate"
  #   key                  = "security-course.terraform.tfstate"
  # }
}

provider "azurerm" {
  features {}
}

# -----------------------------------------------------------------------
# 1. READ EXISTING RESOURCE GROUP
# -----------------------------------------------------------------------

data "azurerm_resource_group" "rg" {
  name = var.rg_name
}

# -----------------------------------------------------------------------
# 2. NETWORK MODULE (isolated network + dedicated subnet for private endpoint)
# -----------------------------------------------------------------------

module "mon_reseau" {
  source                       = "./modules/network"
  rg_name                      = data.azurerm_resource_group.rg.name
  location                     = data.azurerm_resource_group.rg.location
  vnet_name                    = var.vnet_params.name
  vnet_cidr                    = var.vnet_params.vnet_cidr
  db_subnet_cidr               = var.vnet_params.db_subnet_cidr
  private_endpoint_subnet_cidr = var.vnet_params.private_endpoint_subnet_cidr
  bastion_subnet_cidr          = var.vnet_params.bastion_subnet_cidr
  tags                         = var.tags
}

# -----------------------------------------------------------------------
# 3. VM MODULE (small Ubuntu VM in private-endpoints subnet)
# -----------------------------------------------------------------------

module "vm_sql_client" {
  source            = "./modules/vm"
  rg_name           = data.azurerm_resource_group.rg.name
  location          = data.azurerm_resource_group.rg.location
  vm_name           = var.vm_name
  vm_size           = var.vm_size
  admin_username    = var.vm_admin_username
  subnet_id         = module.mon_reseau.private_endpoint_subnet_id
  sql_server_fqdn   = var.sql_server_name
  sql_database_name = var.sql_database_name
  tags              = var.tags
}

# -----------------------------------------------------------------------
# 4. MSSQL MODULE (hardened SQL Server + private access only)
# -----------------------------------------------------------------------

module "ma_base_mssql" {
  source   = "./modules/mssql"
  rg_name  = data.azurerm_resource_group.rg.name
  location = data.azurerm_resource_group.rg.location

  sql_server_name    = var.sql_server_name
  sql_database_name  = var.sql_database_name
  sql_admin_login    = var.sql_admin_login
  sql_admin_password = var.sql_admin_password

  aad_admin_object_id      = module.vm_sql_client.vm_identity_principal_id
  aad_admin_login_username = module.vm_sql_client.vm_identity_login_name

  target_subnet_id = module.mon_reseau.private_endpoint_subnet_id
  vnet_id          = module.mon_reseau.vnet_id

  tags = var.tags
}

# -----------------------------------------------------------------------
# 5. OBSERVABILITY MODULE (private Log Analytics + diagnostics)
# -----------------------------------------------------------------------

module "observability" {
  source                     = "./modules/observability"
  rg_name                    = data.azurerm_resource_group.rg.name
  location                   = data.azurerm_resource_group.rg.location
  vnet_id                    = module.mon_reseau.vnet_id
  private_endpoint_subnet_id = module.mon_reseau.private_endpoint_subnet_id

  log_analytics_workspace_name = var.log_analytics_workspace_name
  log_analytics_retention_days = var.log_analytics_retention_days

  sql_server_id   = module.ma_base_mssql.sql_server_id
  sql_database_id = module.ma_base_mssql.sql_database_id
  vm_id           = module.vm_sql_client.vm_id
  nsg_id          = module.mon_reseau.db_nsg_id

  tags = var.tags
}
