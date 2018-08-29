output "vnet_id" {
  description = "The id of the newly created vNet"
  value       = "${azurerm_virtual_network.vnet.id}"
}

output "vnet_name" {
  description = "The Name of the newly created vNet"
  value       = "${azurerm_virtual_network.vnet.name}"
}

output "vnet_location" {
  description = "The location of the newly created vNet"
  value       = "${azurerm_virtual_network.vnet.location}"
}

output "vnet_address_space" {
  description = "The address space of the newly created vNet"
  value       = "${azurerm_virtual_network.vnet.address_space}"
}

/*
output "vnet_dns_servers" {
  description = "The DNS servers of the newly created vNet"
  value       = "${azurerm_virtual_network.vnet.dns_servers}"
}
*/

output "resource_group_name" {
  value = "${var.resource_group_name}"
}

output "resource_group_id" {
  value = "${azurerm_resource_group.network.id}"
}
