variable "location" {
  type = string
}

variable "rg_name" {
  type = string
}

variable "log_analytics_workspace_name" {
  type = string
}

variable "log_analytics_retention_days" {
  type    = number
  default = 30
}

variable "flow_log_retention_days" {
  type    = number
  default = 7
}

variable "network_watcher_resource_group_name" {
  type    = string
  default = "NetworkWatcherRG"
}

variable "network_watcher_name" {
  type    = string
  default = null
}

variable "vm_front_id" {
  type = string
}

variable "vm_back_id" {
  type = string
}

variable "vnet_id" {
  type = string
}

variable "tags" {
  type = map(string)
}
