variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "France Central"
}

variable "rg_name" {
  description = "Target Resource Group name"
  type        = string
  default     = "RG-MODULAIRE-LAB"
}

variable "vnet_params" {
  description = "Network configuration"
  type = object({
    name                         = string
    vnet_cidr                    = string
    db_subnet_cidr               = string
    private_endpoint_subnet_cidr = string
  })
  default = {
    name                         = "VNET-SECURITY-LAB"
    vnet_cidr                    = "10.40.0.0/16"
    db_subnet_cidr               = "10.40.1.0/24"
    private_endpoint_subnet_cidr = "10.40.2.0/24"
  }
}

variable "sql_server_name" {
  description = "Azure SQL Server name (must be globally unique)"
  type        = string
  default     = "sql-ynov-sec-demo-001"
}

variable "sql_database_name" {
  description = "Database name"
  type        = string
  default     = "appdb"
}

variable "sql_admin_login" {
  description = "SQL admin login used only for break-glass scenarios"
  type        = string
  default     = "sqladminynov"
}

variable "sql_admin_password" {
  description = "Optional SQL admin password. If null, Terraform generates a strong password"
  type        = string
  sensitive   = true
  default     = null
}

variable "aad_admin_object_id" {
  description = "Microsoft Entra ID object ID of SQL logical server admin group/user"
  type        = string
}

variable "aad_admin_login_username" {
  description = "Display name of the Entra admin group/user"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default = {
    project     = "ynov-cloud-module"
    environment = "security-lab"
    owner       = "students"
  }
}
