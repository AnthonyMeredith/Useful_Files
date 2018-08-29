output "id" {
  value = "${azurerm_redis_cache.redis.id}"
}

output "fqdn" {
  value = "${azurerm_redis_cache.redis.hostname}"
}

output "fqdn_custom" {
  value = "${azurerm_dns_cname_record.redis.name}.${var.dns_zone_name}"
}

output "ssl_port" {
  value = "${azurerm_redis_cache.redis.ssl_port}"
}

output "port" {
  value = "${azurerm_redis_cache.redis.port}"
}

output "primary_access_key" {
  value = "${azurerm_redis_cache.redis.primary_access_key}"
}

output "secondary_access_key" {
  value = "${azurerm_redis_cache.redis.secondary_access_key}"
}
