#Azure Generic vNet Module
resource "azurerm_resource_group" "network" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
  tags     = "${var.tags}"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.system_name}vnet"
  location            = "${var.location}"
  address_space       = ["${var.address_space}"]
  resource_group_name = "${azurerm_resource_group.network.name}"
  dns_servers         = "${var.dns_servers}"
  tags                = "${var.tags}"
}
