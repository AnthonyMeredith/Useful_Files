# Projects
variable "system_name" {
  description = "Unique name of the system, ie demo-d-"
}

variable "client" {
  default = "DevOpsGroup"
}

variable "project" {
  default = "demo"
}

variable "env" {
  default = "dev"
}

# network
variable "location" {
  default = "West US 2"
}

variable "dns_zone_name" {
  default = "change_me_please_thanks.com"
}

variable "dns_resource_group_name" {
  default = "demo-glo-dns"
}

variable "address_space" {
  default = "192.168.0.0/23"
}

variable "subnets" {
  type = "map"

  default = {
    demo_management_vms = "192.168.0.16/28"
    demo_management_agw = "192.168.0.32/28"
    demo_delivery_vms   = "192.168.0.48/28"
    demo_delivery_agw   = "192.168.0.64/28"
  }
}

# DevOpsGroup
variable "dog_offices" {
  default = "185.38.247.178/32"
}

# Client
variable "client_offices" {
  default = "8.8.8.8/32"
}

# Application Garms
variable "demo_management_count" {
  description = "Number of demo editor virtual machines that should be created"
  default     = 1
}

variable "demo_management_size" {
  description = "VM Size"
  default     = "Standard_B2S"
}

variable "demo_delivery_count" {
  description = "Number of demo delivery virtual machines that should be created"
  default     = 1
}

variable "demo_delivery_size" {
  description = "VM Size"
  default     = "Standard_B2S"
}

variable "webserver_password" {
  description = "Number of demo editor virtual machines that should be created"
  default     = "ZonePa55!!"
}

variable "webserver_username" {
  description = "Number of demo editor virtual machines that should be created"
  default     = "zoneadmin"
}

#sql

variable "sql_user" {
  default = "dogadmin"
}

variable "sql_password" {
  default = "thisIsDog111"
}

variable "sql_edition" {
  default = "Standard"
}

variable "sql_rso_name" {
  default = "S0"
}
