output "public_ips" {
  value = "${azurerm_public_ip.vm.*.ip_address}"
}

output "private_ips" {
  value = "${azurerm_network_interface.vm.*.private_ip_address}"
}

output "fqdn_custom" {
  value = "${formatlist("%s.%s", azurerm_dns_a_record.vm.*.name, azurerm_dns_a_record.vm.*.zone_name)}"
}

output "agw_fqdn" {
  value = "${element(concat(azurerm_public_ip.agw.*.fqdn, list("")), 0)}"
}

output "agw_fqdn_custom" {
  value = "${element(concat(azurerm_dns_cname_record.agw.*.name, list("")), 0)}.${var.dns_zone_name}"
}
