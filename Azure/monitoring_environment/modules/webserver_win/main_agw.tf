# network bits needed by application gateway, must be in its own solo subnet
resource "azurerm_subnet" "agw" {
  count                     = "${var.agw_enabled}"
  name                      = "${var.system_name}-agw"
  resource_group_name       = "${var.resource_group_name_network}"
  virtual_network_name      = "${var.vnet_name}"
  address_prefix            = "${var.agw_address_prefix}"
  network_security_group_id = "${azurerm_network_security_group.agw.id}"
}

resource "azurerm_network_security_group" "agw" {
  count               = "${var.agw_enabled}"
  name                = "${var.system_name}-agw"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name_network}"
  tags                = "${var.tags}"
}

resource "azurerm_network_security_rule" "agw_probe" {
  count                       = "${var.agw_enabled}"
  name                        = "${var.system_name}-alb-probe"
  priority                    = "1001"
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "65503-65534"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name_network}"
  network_security_group_name = "${azurerm_network_security_group.agw.name}"
  depends_on                  = ["azurerm_network_security_group.agw"]
  description                 = "AGW - Somehow used for heathcheck probe"
}

resource "azurerm_network_security_rule" "agw_dog_whitelist" {
  count                       = "${var.agw_enabled}"
  count                       = "${length(split(",", var.dog_whitelist))}"
  name                        = "${var.system_name}-dog_whitelist${count.index+1}"
  priority                    = "${count.index + 1101}"
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "${element(split(",", var.dog_whitelist), count.index)}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name_network}"
  network_security_group_name = "${azurerm_network_security_group.agw.name}"
  depends_on                  = ["azurerm_network_security_group.agw"]
  description                 = "DOG Whitelist - ${element(split(",", var.dog_whitelist), count.index)}"
}

resource "azurerm_network_security_rule" "agw_client_offices" {
  count                       = "${var.agw_enabled}"
  count                       = "${length(split(",", var.client_whitelist))}"
  name                        = "${var.system_name}-client_whitelist${count.index+1}"
  priority                    = "${count.index + 1201}"
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "${element(split(",", var.client_whitelist), count.index)}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name_network}"
  network_security_group_name = "${azurerm_network_security_group.agw.name}"
  depends_on                  = ["azurerm_network_security_group.agw"]
  description                 = "Client Whitelist - #${count.index+1} - ${element(split(",", var.client_whitelist), count.index)}"
}

resource "azurerm_network_security_rule" "agw_whitelist_http" {
  count                       = "${var.agw_enabled}"
  count                       = "${length(split(",", var.agw_whitelist))}"
  name                        = "${var.system_name}-whitelist${count.index+1}"
  priority                    = "${count.index + 1401}"
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "${element(split(",", var.agw_whitelist), count.index)}"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name_network}"
  network_security_group_name = "${azurerm_network_security_group.agw.name}"
  depends_on                  = ["azurerm_network_security_group.agw"]
  description                 = "CDN Ranges - #${count.index+1} - ${element(split(",", var.agw_whitelist), count.index)}"
}

resource "azurerm_public_ip" "agw" {
  count                        = "${var.agw_enabled}"
  name                         = "${var.system_name}-agw${count.index+1}"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.vm.name}"
  public_ip_address_allocation = "dynamic"
  domain_name_label            = "${var.system_name}-agw${count.index+1}"
}

# Create an application gateway
resource "azurerm_application_gateway" "agw" {
  count               = "${var.agw_enabled}"
  name                = "${var.system_name}-agw${count.index+1}"
  resource_group_name = "${azurerm_resource_group.vm.name}"
  location            = "${var.location}"

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "${var.system_name}-agw-config"
    subnet_id = "${azurerm_subnet.agw.id}"
  }

  frontend_port {
    name = "${var.system_name}-agw-fehttpport"
    port = 80
  }

  frontend_port {
    name = "${var.system_name}-agw-fehttpport_private"
    port = 8080
  }

  frontend_ip_configuration {
    name                 = "${var.system_name}-agw${count.index+1}-feip"
    public_ip_address_id = "${element(azurerm_public_ip.agw.*.id, count.index)}"
  }

  backend_address_pool {
    name            = "${var.system_name}-agw-beap"
    ip_address_list = ["${azurerm_network_interface.vm.*.private_ip_address}"]
  }

  backend_http_settings {
    name                  = "${var.system_name}-agw-be-http"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 120
    probe_name            = "http"
  }

  http_listener {
    name                           = "${var.system_name}-agw-httplstn"
    frontend_ip_configuration_name = "${var.system_name}-agw${count.index+1}-feip"
    frontend_port_name             = "${var.system_name}-agw-fehttpport"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "${var.system_name}-agw-rqrt-http"
    rule_type                  = "Basic"
    http_listener_name         = "${var.system_name}-agw-httplstn"
    backend_address_pool_name  = "${var.system_name}-agw-beap"
    backend_http_settings_name = "${var.system_name}-agw-be-http"
  }

  probe {
    name                = "http"
    protocol            = "http"
    path                = "/"
    host                = "${element(var.agw_probe_host, count.index)}"
    interval            = "15"
    timeout             = "30"
    unhealthy_threshold = "3"
  }

  tags       = "${var.tags}"
  depends_on = ["azurerm_virtual_machine.vm", "azurerm_public_ip.agw"]

  lifecycle {
    ignore_changes = ["backend_http_settings"] # messes up when instances are added via autoscale, once provisioned this shouldnt need to be set again.
  }
}

resource "azurerm_dns_cname_record" "agw" {
  count = "${var.agw_enabled}"
  name  = "${element(azurerm_public_ip.agw.*.name, count.index)}"

  zone_name           = "${var.dns_zone_name}"
  resource_group_name = "${var.dns_resource_group_name}"
  ttl                 = 300
  record              = "${element(azurerm_public_ip.agw.*.fqdn, count.index)}"
  depends_on          = ["azurerm_application_gateway.agw"]

  tags = "${var.tags}"
}
