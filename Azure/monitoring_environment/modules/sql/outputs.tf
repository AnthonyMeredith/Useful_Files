output "fqdn" {
  value = "${azurerm_sql_server.sql.fully_qualified_domain_name}"
}

output "fqdn_custom" {
  value = "${azurerm_dns_cname_record.sql.name}.${azurerm_dns_cname_record.sql.zone_name}"
}
