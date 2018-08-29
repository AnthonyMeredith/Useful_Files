#
# VMs, Nics, Disk, availability sets...
#

resource "azurerm_resource_group" "vm" {
  name     = "${var.system_name}"
  location = "${var.location}"

  tags = "${var.tags}"
}

resource "azurerm_network_interface" "vm" {
  count               = "${var.vm_count}"
  name                = "${var.system_name}${count.index+1}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.vm.name}"

  ip_configuration {
    name                          = "${var.system_name}${count.index+1}"
    subnet_id                     = "${azurerm_subnet.vm.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${element(azurerm_public_ip.vm.*.id, count.index)}"
  }

  tags = "${var.tags}"
}

resource "azurerm_public_ip" "vm" {
  count                        = "${var.vm_count}"
  name                         = "${var.system_name}${count.index+1}"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.vm.name}"
  public_ip_address_allocation = "static"
  domain_name_label            = "${var.system_name}${count.index+1}"
}

resource "azurerm_managed_disk" "f" {
  count                = "${var.vm_count}"
  name                 = "${var.system_name}${count.index+1}-f"
  location             = "${var.location}"
  resource_group_name  = "${azurerm_resource_group.vm.name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "80"
}

resource "azurerm_virtual_machine" "vm" {
  depends_on            = ["azurerm_network_security_rule.dog_whitelist"]
  count                 = "${var.vm_count}"
  name                  = "${var.system_name}${count.index+1}"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.vm.name}"
  network_interface_ids = ["${element(azurerm_network_interface.vm.*.id, count.index)}"]
  availability_set_id   = "${azurerm_availability_set.vm.id}"
  vm_size               = "${var.vm_size}"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.system_name}${count.index+1}-c"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  # Optional data disks

  storage_data_disk {
    name            = "${element(azurerm_managed_disk.f.*.name, count.index)}"
    managed_disk_id = "${element(azurerm_managed_disk.f.*.id, count.index)}"
    create_option   = "Attach"
    lun             = 1
    disk_size_gb    = "${element(azurerm_managed_disk.f.*.disk_size_gb, count.index)}"
  }
  os_profile {
    computer_name  = "${var.system_name}${count.index+1}"
    admin_username = "${var.vm_user}"
    admin_password = "${var.vm_password}"
    custom_data    = "${file("${path.module}/main_vms_scripts/deploy.ps1")}"
  }
  os_profile_windows_config {
    provision_vm_agent        = true
    enable_automatic_upgrades = false

    #Unattend config is to enable basic auth in WinRM, required for the chef provisioner stage.
    additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "FirstLogonCommands"
      content      = "${file("${path.module}/main_vms_scripts/FirstLogonCommands.xml")}"
    }

    additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "AutoLogon"
      content      = "<AutoLogon><Username>${var.vm_user}</Username><Password><Value>${var.vm_password}</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount></AutoLogon>"
    }
  }
  connection {
    host     = "${element(azurerm_public_ip.vm.*.ip_address, count.index)}"
    type     = "winrm"
    user     = "${var.vm_user}"
    password = "${var.vm_password}"
  }
  tags = "${var.tags}"
}

resource "azurerm_availability_set" "vm" {
  name                         = "${var.system_name}"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.vm.name}"
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}

#
# Networking & Security 
#

resource "azurerm_subnet" "vm" {
  name                      = "${var.system_name}"
  resource_group_name       = "${var.resource_group_name_network}"
  virtual_network_name      = "${var.vnet_name}"
  address_prefix            = "${var.vm_address_prefix}"
  network_security_group_id = "${azurerm_network_security_group.vm.id}"
}

resource "azurerm_network_security_group" "vm" {
  name                = "${var.system_name}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name_network}"
  tags                = "${var.tags}"
}

resource "azurerm_network_security_rule" "vm_agw_probe" {
  count                       = "${var.agw_enabled}"
  name                        = "${var.system_name}-agw-probe"
  priority                    = "1502"
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "65503-65534"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name_network}"
  network_security_group_name = "${var.system_name}"
  depends_on                  = ["azurerm_network_security_group.vm"]
  description                 = "AGW - Somehow used for heathcheck probe"
}

resource "azurerm_network_security_rule" "dog_whitelist" {
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
  network_security_group_name = "${var.system_name}"
  depends_on                  = ["azurerm_network_security_group.vm"]
  description                 = "DOG IP Whitelisting - ${element(split(",", var.dog_whitelist), count.index)}"
}

resource "azurerm_dns_a_record" "vm" {
  count = "${var.vm_count}"
  name  = "${var.system_name}${count.index+1}"

  zone_name           = "${var.dns_zone_name}"
  resource_group_name = "${var.dns_resource_group_name}"
  ttl                 = 300
  records             = ["${element(azurerm_public_ip.vm.*.ip_address, count.index)}"]

  tags = "${var.tags}"
}
