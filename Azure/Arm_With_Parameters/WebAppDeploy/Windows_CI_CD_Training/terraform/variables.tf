variable "resourcegroup_name" {
  description = "The name of the main resource group"
}

variable "resourcegroup_location" {
  description = "The location of the resource group"
  default     = "East US"
}

variable "buildserver_user" {
  description = "Buildserver login credentials - username"
  default     = "techtest"
}

variable "buildserver_password" {
  description = "Buildserver login credentials - password"
}

variable "buildserver_hostname" {
  description = "Defining hostname"
  default     = "localhost"
}

variable "sql_user" {
  description = "SQL login credentials - username"
  default     = "buildserver\\techtest"
}

variable "test_date" {
  description = "When the test will take place - format dd/mm/yyyy"
}

variable "admin_public_ip" {
  description = "The public IP of the administrator, allows RDP/WinRM access to remote employees"
}
