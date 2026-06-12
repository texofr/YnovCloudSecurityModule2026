rg_name               = "RG-B3-Eric"
acr_name_prefix       = "acrynovlaboepe"
app_service_plan_name = "asp-ynov-labo-epe"
app_service_plan_sku  = "B1"
web_app_name_prefix   = "app-ynov-labo-epe"
docker_image_name     = "ynov-webapp"
docker_image_tag      = "latest"

tags = {
  project     = "ynov-cloud-module"
  environment = "lab"
  owner       = "students"
}
