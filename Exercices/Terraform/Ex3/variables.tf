variable "rg_name" {
  description = "Target Resource Group name"
  type        = string
  default     = "RG-MODULAIRE-LAB"
}

variable "acr_name_prefix" {
  description = "ACR name prefix (letters/numbers only)"
  type        = string
  default     = "acrynovlaboepe"
}

variable "app_service_plan_name" {
  description = "App Service Plan name"
  type        = string
  default     = "asp-ynov-labo-epe"
}

variable "app_service_plan_sku" {
  description = "App Service Plan SKU for Linux Web App"
  type        = string
  default     = "B1"
}

variable "web_app_name_prefix" {
  description = "Web App name prefix"
  type        = string
  default     = "app-ynov-labo-epe"
}

variable "docker_image_name" {
  description = "Docker repository name inside ACR"
  type        = string
  default     = "ynov-webapp"
}

variable "docker_image_tag" {
  description = "Docker tag used by the Web App"
  type        = string
  default     = "latest"
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default = {
    project     = "ynov-cloud-module"
    environment = "lab"
    owner       = "students"
  }
}
