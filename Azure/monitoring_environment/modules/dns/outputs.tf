output "zone_name" {
  value = "${azurerm_dns_zone.dns.name}"
}

output "resource_group_name" {
  value = "${azurerm_resource_group.dns.name}"
}
