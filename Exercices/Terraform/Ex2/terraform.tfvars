location = "North Europe"
rg_name  = "RG-B3-Eric"

# IMPORTANT:
# sql_server_name must be globally unique in Azure.
sql_server_name   = "sql-ynov-sec-demo-001"
sql_database_name = "studentappdb"
sql_admin_login   = "sqladminynov"

# Recommended: keep this null so Terraform generates a strong password.
# For production, store credentials in CI/CD secret vaults.
sql_admin_password = null

vm_name           = "vm-sql-client-001"
vm_size           = "Standard_D2als_v6"
vm_admin_username = "azureuser"

log_analytics_workspace_name = "law-security-private-001"
log_analytics_retention_days = 30

vnet_params = {
  name                         = "VNET-SECURITY-LAB"
  vnet_cidr                    = "10.40.0.0/16"
  db_subnet_cidr               = "10.40.1.0/24"
  private_endpoint_subnet_cidr = "10.40.2.0/24"
  bastion_subnet_cidr          = "10.40.3.0/26"
}

tags = {
  project     = "ynov-cloud-module"
  environment = "security-lab-ex2"
  owner       = "students"
}
