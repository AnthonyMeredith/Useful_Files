variable "system_name" {
  description = "The system name"
  default     = "system_name"
}

variable "resource_group_name" {
  description = "Default resource group name that the network will be created in."
  default     = "myapp-rg"
}

variable "location" {
  description = "The location/region where the core network will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
  default     = "West US 2"
}

variable "zone_name" {
  description = "The dns zone name"
  default     = "changeme.com"
}

variable "tags" {
  type = "map"

  default = {
    tag1 = ""
    tag2 = ""
  }
}
