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

# Replace with your Entra ID group/object information.
aad_admin_object_id      = "ad9ba63a-6230-4110-b48d-18285b2ba53c"
aad_admin_login_username = "sql-admins-ynov"

vnet_params = {
  name                         = "VNET-SECURITY-LAB"
  vnet_cidr                    = "10.40.0.0/16"
  db_subnet_cidr               = "10.40.1.0/24"
  private_endpoint_subnet_cidr = "10.40.2.0/24"
}

tags = {
  project     = "ynov-cloud-module"
  environment = "security-lab"
  owner       = "students"
}
