resource "azurerm_resource_group" "sql" {
  name     = "${var.system_name}"
  location = "${var.location}"
}

resource "azurerm_sql_server" "sql" {
  name                         = "${var.system_name}"
  resource_group_name          = "${azurerm_resource_group.sql.name}"
  location                     = "${azurerm_resource_group.sql.location}"
  version                      = "12.0"
  administrator_login          = "${var.administrator_login}"
  administrator_login_password = "${var.administrator_login_password}"

  tags = "${var.tags}"
}


resource "azurerm_sql_database" "sql" {
  count               = "${length(var.databases)}"
  name                = "${element(var.databases, count.index)}"
  resource_group_name = "${azurerm_resource_group.sql.name}"
  location            = "${azurerm_resource_group.sql.location}"
  server_name         = "${azurerm_sql_server.sql.name}"

  edition                          = "${var.edition}"
  requested_service_objective_name = "${var.requested_service_objective_name}"

  tags = "${var.tags}"
}

resource "azurerm_sql_firewall_rule" "azure_access" {
  name                = "Azure Access"
  resource_group_name = "${azurerm_resource_group.sql.name}"
  server_name         = "${azurerm_sql_server.sql.name}"
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_sql_firewall_rule" "dog_whitelist" {
  count               = "${length(split(",", var.dog_whitelist))}"
  name                = "${var.system_name}-dog_whitelist${count.index+1}"
  resource_group_name = "${azurerm_resource_group.sql.name}"
  server_name         = "${azurerm_sql_server.sql.name}"
  start_ip_address    = "${cidrhost(element(split(",", var.dog_whitelist), count.index), 0)}"
  end_ip_address      = "${cidrhost(element(split(",", var.dog_whitelist), count.index), 0)}"
}

resource "azurerm_sql_firewall_rule" "client_office" {
  count               = "${length(split(",", var.client_whitelist))}"
  name                = "${var.system_name}-client_office${count.index+1}"
  resource_group_name = "${azurerm_resource_group.sql.name}"
  server_name         = "${azurerm_sql_server.sql.name}"
  start_ip_address    = "${cidrhost(element(split(",", var.client_whitelist), count.index), 0)}"
  end_ip_address      = "${cidrhost(element(split(",", var.client_whitelist), count.index), 0)}"
}

resource "azurerm_sql_firewall_rule" "servers" {
  count               = "${var.server_whitelist_count}"
  name                = "${var.system_name}-server${count.index+1}"
  resource_group_name = "${azurerm_resource_group.sql.name}"
  server_name         = "${azurerm_sql_server.sql.name}"
  start_ip_address    = "${element(split(",", var.server_whitelist), count.index)}"
  end_ip_address      = "${element(split(",", var.server_whitelist), count.index)}"
}

resource "azurerm_sql_firewall_rule" "azure" {
  name                = "Azure services"
  resource_group_name = "${azurerm_resource_group.sql.name}"
  server_name         = "${azurerm_sql_server.sql.name}"
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_dns_cname_record" "sql" {
  name                = "${var.system_name}"
  zone_name           = "${var.dns_zone_name}"
  resource_group_name = "${var.dns_resource_group_name}"
  ttl                 = 300
  record              = "${azurerm_sql_server.sql.fully_qualified_domain_name}"

  tags = "${var.tags}"
}
