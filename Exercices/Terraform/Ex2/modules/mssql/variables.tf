variable "location" {
  type = string
}

variable "rg_name" {
  type = string
}

variable "sql_server_name" {
  type = string
}

variable "sql_database_name" {
  type = string
}

variable "sql_admin_login" {
  type = string
}

variable "sql_admin_password" {
  type      = string
  sensitive = true
  default   = null
}

variable "aad_admin_object_id" {
  type = string
}

variable "aad_admin_login_username" {
  type = string
}

variable "target_subnet_id" {
  type = string
}

variable "vnet_id" {
  type = string
}

variable "tags" {
  type = map(string)
}
