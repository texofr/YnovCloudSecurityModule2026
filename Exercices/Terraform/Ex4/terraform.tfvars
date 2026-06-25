rg_name                             = "RG-B3-Eric"
vnet_name                           = "vnet-ex4-lab"
vnet_cidr                           = "10.50.0.0/16"
frontend_subnet_name                = "FrontendSubnet"
frontend_subnet_cidr                = "10.50.1.0/24"
backend_subnet_name                 = "BackendSubnet"
backend_subnet_cidr                 = "10.50.2.0/24"
frontend_nsg_name                   = "nsg-ex4-frontend"
frontend_open_rule_name             = "allow-http-from-internet"
vm_front_name                       = "vm-front-001"
vm_back_name                        = "vm-back-001"
vm_size                             = "Standard_D2pls_v6"
vm_admin_username                   = "azureuser"
log_analytics_workspace_name        = "law-ex4-lab"
log_analytics_retention_days        = 30
flow_log_retention_days             = 7
network_watcher_resource_group_name = "NetworkWatcherRG"
# Optionally force a specific watcher name, otherwise computed from location.
network_watcher_name = null

tags = {
  project     = "ynov-cloud-module"
  environment = "ctf-lab"
  owner       = "students"
  exercise    = "ex4"
}
