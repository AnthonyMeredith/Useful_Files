variable "image_name" {
  description = "The name of the existing Golden Image"
  default = "CiCdImg1"
}

variable "image_resource_group" {
  description = "The name of the Resource Group where the Golden Image is located."
  default = "TestResourceGroup2"
}

variable "resourcegroup_name" {
  description = "The name of the main resource group"
}

variable "resourcegroup_location" {
  description = "The location of the resource group"
  default     = "West US 2"
}

variable "buildserver_user" {
  description = "Training login credentials - username"
  default     = "techtest"
}

variable "buildserver_password" {
  description = "Training login credentials - password"
}

variable "buildserver_hostname" {
  description = "Defining hostname"
  default     = "localhost"
}

variable "sql_user" {
  description = "SQL login credentials - username"
  default     = "ghqc367xzy\\techtest"
}

variable "admin_public_ip" {
  description = "The public IP of the administrator, allows RDP/WinRM access to remote employees"
}

variable "sub_id" {
  description = "The name of the existing Golden Image"
}

variable "client_id" {
  description = "The name of the Resource Group where the Golden Image is located."
}

variable "client_secret" {
  description = "The name of the main resource group"
}

variable "tenant_id" {
  description = "The location of the resource group"
}
