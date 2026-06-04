variable "location" {
  type = string
}

variable "rg_name" {
  type = string
}

variable "vnet_id" {
  type = string
}

variable "private_endpoint_subnet_id" {
  type = string
}

variable "log_analytics_workspace_name" {
  type = string
}

variable "log_analytics_retention_days" {
  type = number
}

variable "sql_server_id" {
  type = string
}

variable "sql_database_id" {
  type = string
}

variable "vm_id" {
  type = string
}

variable "nsg_id" {
  type = string
}

variable "tags" {
  type = map(string)
}
