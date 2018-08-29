variable "resourcegroup_name" {
  description = "The name of the main resource group"
}

variable "resourcegroup_location" {
  description = "The location of the resource group"
  default     = "West US 2"
}

variable "CICD_user" {
  description = "Buildserver login credentials - username"
  default     = "techtest"
}

variable "CICD_password" {
  description = "Buildserver login credentials - password"
}

variable "CICD_hostname" {
  description = "Defining hostname"
  default     = "localhost"
}

variable "sql_user" {
  description = "SQL login credentials - username"
  default     = "CICD\\techtest"
}

variable "test_date" {
  description = "When the test will take place - format dd/mm/yyyy"
}

variable "admin_public_ip" {
  description = "The public IP of the administrator, allows RDP/WinRM access to remote employees"
}