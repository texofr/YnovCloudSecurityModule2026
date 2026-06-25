variable "location" {
  type = string
}

variable "rg_name" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "vnet_cidr" {
  type = string
}

variable "frontend_subnet_name" {
  type = string
}

variable "frontend_subnet_cidr" {
  type = string
}

variable "backend_subnet_name" {
  type = string
}

variable "backend_subnet_cidr" {
  type = string
}

variable "frontend_nsg_name" {
  type = string
}

variable "frontend_open_rule_name" {
  type = string
}

variable "tags" {
  type = map(string)
}
