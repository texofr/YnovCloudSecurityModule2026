variable "location" {
  type = string
}

variable "rg_name" {
  type = string
}

variable "vm_front_name" {
  type = string
}

variable "vm_back_name" {
  type = string
}

variable "vm_size" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "frontend_subnet_id" {
  type = string
}

variable "backend_subnet_id" {
  type = string
}

variable "backend_subnet_cidr" {
  type = string
}

variable "tags" {
  type = map(string)
}
