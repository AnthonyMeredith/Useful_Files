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

variable "test_date" {
  description = "When the test will take place - format dd/mm/yyyy"
}

variable "admin_public_ip" {
  description = "The public IP of the administrator, allows RDP/WinRM access to remote employees"
}
