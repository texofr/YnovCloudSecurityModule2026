variable "location" {
  type = string
}

variable "rg_name" {
  type = string
}

variable "vm_name" {
  type = string
}

variable "vm_size" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "sql_server_fqdn" {
  type = string
}

variable "sql_database_name" {
  type = string
}

variable "tags" {
  type = map(string)
}
