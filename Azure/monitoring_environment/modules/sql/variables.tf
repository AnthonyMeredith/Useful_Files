variable "location" {
  default = "West US 2"
}

variable "system_name" {
  default = "atb-d-"
}

variable "dns_zone_name" {
  default = "changeme.com"
}

variable "dns_resource_group_name" {
  default = "changeme-rg"
}

variable "administrator_login" {
  default = "mradministrator"
}

variable "administrator_login_password" {
  default = "thisIsDog11"
}

variable "tags" {
  default = {
    env     = "dev"
    project = "Changeme Project"
  }
}

variable "requested_service_objective_name" {
  default = "S0"
}

variable "edition" {
  default = "Default"
}


variable "databases" {
  default = ["Default"]
}

variable "dog_whitelist" {}

variable "client_whitelist" {}

variable "server_whitelist" {}

variable "server_whitelist_count" {}
