variable "system_name" {
  description = "The system name"
  default     = "system_name"
}

variable "location" {
  description = "The location/region where the core network will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
  default     = "West US 2"
}

variable "capacity" {
  description = "capacity in GB"
  default     = 1
}

variable "dns_zone_name" {
  default = "changeme.com"
}

variable "dns_resource_group_name" {
  default = "changeme-rg"
}

variable "tags" {
  default = {
    env     = "dev"
    project = "Changeme Project"
  }
}
