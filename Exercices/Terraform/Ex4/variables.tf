variable "rg_name" {
  description = "Target Resource Group name"
  type        = string
  default     = "RG-MODULAIRE-LAB"
}

variable "vnet_name" {
  description = "Virtual network name"
  type        = string
  default     = "vnet-ex4-lab"
}

variable "vnet_cidr" {
  description = "Address space for the VNet"
  type        = string
  default     = "10.50.0.0/16"
}

variable "frontend_subnet_name" {
  description = "Frontend subnet name"
  type        = string
  default     = "FrontendSubnet"
}

variable "frontend_subnet_cidr" {
  description = "Frontend subnet CIDR"
  type        = string
  default     = "10.50.1.0/24"
}

variable "backend_subnet_name" {
  description = "Backend subnet name"
  type        = string
  default     = "BackendSubnet"
}

variable "backend_subnet_cidr" {
  description = "Backend subnet CIDR"
  type        = string
  default     = "10.50.2.0/24"
}

variable "frontend_nsg_name" {
  description = "Frontend NSG name"
  type        = string
  default     = "nsg-ex4-frontend"
}

variable "frontend_open_rule_name" {
  description = "Name of the intentionally permissive frontend rule"
  type        = string
  default     = "allow-http-from-internet"
}

variable "vm_front_name" {
  description = "Frontend VM name"
  type        = string
  default     = "vm-front-001"
}

variable "vm_back_name" {
  description = "Backend VM name"
  type        = string
  default     = "vm-back-001"
}

variable "vm_size" {
  description = "Size for both Linux VMs"
  type        = string
  default     = "Basic_A1"
}

variable "vm_admin_username" {
  description = "Admin username used on both VMs"
  type        = string
  default     = "azureuser"
}

variable "log_analytics_workspace_name" {
  description = "Log Analytics workspace name"
  type        = string
  default     = "law-ex4-lab"
}

variable "log_analytics_retention_days" {
  description = "Retention in days for Log Analytics"
  type        = number
  default     = 30
}

variable "flow_log_retention_days" {
  description = "Retention in days for NSG flow logs"
  type        = number
  default     = 7
}

variable "network_watcher_resource_group_name" {
  description = "Resource group containing Network Watcher"
  type        = string
  default     = "NetworkWatcherRG"
}

variable "network_watcher_name" {
  description = "Optional network watcher name override"
  type        = string
  default     = null
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default = {
    project     = "ynov-cloud-module"
    environment = "ctf-lab"
    owner       = "students"
    exercise    = "ex4"
  }
}
