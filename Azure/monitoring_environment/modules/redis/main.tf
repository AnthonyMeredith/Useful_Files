resource "azurerm_resource_group" "redis" {
  name     = "${var.system_name}"
  location = "${var.location}"
}

resource "azurerm_redis_cache" "redis" {
  name                = "${var.system_name}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.redis.name}"
  capacity            = "${var.capacity}"
  family              = "C"
  sku_name            = "Standard"
  enable_non_ssl_port = false

  redis_configuration {}
}

resource "azurerm_dns_cname_record" "redis" {
  name                = "${var.system_name}"
  zone_name           = "${var.dns_zone_name}"
  resource_group_name = "${var.dns_resource_group_name}"
  ttl                 = 300
  record              = "${azurerm_redis_cache.redis.hostname}"

  tags = "${var.tags}"
}
