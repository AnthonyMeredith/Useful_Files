variable "system_name" {
  default = "atb-d-"
}

variable "resource_group_name" {
  default = "atb-d-vm-rg"
}

variable "location" {
  default = "West US 2"
}

variable "dog_whitelist" {
  default = "192.168.0.1"
}

variable "vnet_name" {}

variable "client_whitelist" {
  default = "192.168.0.1"
}

variable "dns_zone_name" {
  default = "changeme.com"
}

variable "resource_group_name_network" {}

variable "tags" {
  default = {
    env     = "dev"
    project = "Changeme Project"
  }
}

variable "dns_resource_group_name" {
  default = "changeme-rg"
}

variable "project" {
  default = "Changeme Project"
}

variable "vm_count" {
  description = "Number of virtual machines that should be created"
  default     = 2
}

variable "vm_user" {
  description = "username of user created on VMs"
  default     = "zoneadmin"
}

variable "vm_password" {
  description = "Pssword for the user created on VMs"
  default     = "ZonePa55!!"
}

variable "vm_size" {
  description = "Size of the VMs we are creating"
  default     = "Standard_DS1_v2"
}

variable "vm_address_prefix" {}

variable "agw_address_prefix" {}

variable "agw_whitelist" {
  default = "192.168.0.1"
}

variable "agw_enabled" {
  default = "1"
}

variable "agw_probe_host" {
  type    = "list"
  default = ["localhost"]
}
