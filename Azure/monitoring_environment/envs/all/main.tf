#-------------------------------------------------------------- #
# This creates all resources necessary for the Demo             #
# environment, Editors, Delivery, SQL & Redis.                  #
#-------------------------------------------------------------- #

#
# Create networking
#

module "network" {
  source              = "../../modules/network"
  resource_group_name = "${var.system_name}network"
  location            = "${var.location}"
  address_space       = "${var.address_space}"      # IP address space used for the network, subnets will x§be created in this space
  system_name         = "${var.system_name}"

  tags = {
    env     = "${var.env}"
    client  = "${var.client}"
    project = "${var.project}"
  }
}

module "dns" {
  source              = "../../modules/dns"
  resource_group_name = "${var.system_name}dns"
  location            = "${var.location}"
  zone_name           = "${var.env}.${var.dns_zone_name}"

  tags = {
    env     = "${var.env}"
    client  = "${var.client}"
    project = "${var.project}"
  }
}

#
# Create VMs
#

#
# Demo Delivery Servers
#

module "demo_delivery" {
  source                      = "../../modules/webserver_win"
  location                    = "${var.location}"
  vnet_name                   = "${module.network.vnet_name}"
  system_name                 = "${var.system_name}del"                 #name prefix         # Name of servers and other resources, nics, disks etc...
  resource_group_name_network = "${module.network.resource_group_name}" # Name of the networking resource group so subnets can be created
  dog_whitelist               = "${var.dog_offices}"                    # Range of Zone office IPs for whitelisting inbound traffic
  client_whitelist            = "${var.client_offices}"

  dns_zone_name           = "${module.dns.zone_name}"
  dns_resource_group_name = "${module.dns.resource_group_name}"

  vm_count          = "${var.demo_delivery_count}"                  # Number of servers we are spinning up
  vm_size           = "${var.demo_delivery_size}"                   # Size of the servers we are spinning up
  vm_user           = "${var.webserver_username}"                   # Name of the user account created on VM
  vm_password       = "${var.webserver_password}"                   # Password of the user account created on VM
  vm_address_prefix = "${lookup(var.subnets, "demo_delivery_vms")}" # Subnet to create and put the VMs in

  agw_enabled        = "1"
  agw_whitelist      = "0.0.0.0/0"
  agw_address_prefix = "${lookup(var.subnets, "demo_delivery_agw")}"
  agw_probe_host     = ["mysite.com"]

  tags = {
    env     = "${var.env}"
    project = "${var.project}"
    client  = "${var.client}"
    purpose = "Delivery application windows web farm"
    vnet    = "${module.network.vnet_id} + ${module.network.resource_group_id}"
  }
}

/*
#
#  Management Servers
#
module "demo_management" {
  source                  = "../../modules/webserver_win"
  location                = "${var.location}"
  env                     = "${var.env}"
  system_name             = "${var.system_name}scm"                         # Name of servers and other resources, nics, disks etc...
  dns_zone_name           = "${module.dns.zone_name}"
  dns_resource_group_name = "${module.dns.resource_group_name}"
  count                   = "${var.sitecore_management_count}"              # Number of servers we are spinning up
  size                    = "${var.sitecore_management_size}"               # Size of the servers we are spinning up
  user                    = "${var.webserver_username}"                     # Name of the user account created on VM
  password                = "${var.webserver_password}"                     # Password of the user account created on VM
  run_list                = "${var.sitecore_management_run_list}"
  chef_key                = "${var.chef_key}"
  address_prefix          = "${lookup(var.subnets, "sitecore_management")}" # Subnet to create and put the VMs in

  virtual_network_name        = "${module.network.vnet_name}"           # VNet subnets are created in
  dog_whitelist               = "${var.zone_offices}"                   # Range of Zone office IPs for whitelisting inbound traffic
  client_whitelist            = "${var.client_offices}"
  cdn_whitelist               = "${var.cdn_ranges}"
  azure_ukwest_whitelist      = "${var.azure_ukwest_whitelist}"
  resource_group_name_network = "${module.network.resource_group_name}" # Name of the networking resource group so subnets can be created

  address_prefix-agw = "${lookup(var.subnets, "sitecore_management-agw")}"
  ssl_cert           = ["${file("cert_bar.pfx")}"]
  ssl_cert_pass      = ["${var.ssl_cert_pass_bar}"]
  count_agw          = "1"
  probe_host         = ["bdw-${var.env}.barratthomes.co.uk"]

  tags = {
    env     = "${var.env}"
    project = "${var.project} - Sitecore Management"
    vnet    = "${module.network.vnet_id} + ${module.network.resource_group_id}" # only add this to ensure vnet is created before this
  }
}
*/

#
# SQL Cluster
#
module "demo_sql" {
  source                  = "../../modules/sql"
  location                = "${var.location}"
  system_name             = "${var.system_name}sdb1"
  dns_zone_name           = "${module.dns.zone_name}"
  dns_resource_group_name = "${module.dns.resource_group_name}"

  administrator_login              = "${var.sql_user}"
  administrator_login_password     = "${var.sql_password}"
  edition                          = "${var.sql_edition}"
  requested_service_objective_name = "${var.sql_rso_name}"
  databases                        = ["art-db"]
  dog_whitelist                    = "${var.dog_offices}"
  client_whitelist                 = "${var.client_offices}"
  server_whitelist                 = "${join(",", concat(module.demo_delivery.public_ips))}"
  server_whitelist_count           = "${var.demo_delivery_count}"

  tags = {
    env     = "${var.env}"
    project = "${var.project}"
    client  = "${var.client}"
    purpose = "SQL Server for use by web x y z"
  }
}

#
# Redis
#
/*
module "redis" {
  source                  = "../../modules/redis"
  capacity                = 2
  location                = "${var.location}"
  system_name             = "${var.system_name}ss1"
  dns_zone_name           = "${module.dns.zone_name}"
  dns_resource_group_name = "${module.dns.resource_group_name}"

  tags = {
    env     = "${var.env}"
    project = "${var.project}"
    client  = "${var.client}"
    purpose = "Redis used for session state by x y z"
  }
}
*/

