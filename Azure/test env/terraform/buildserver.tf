provider "azurerm" {
  version = "1.7.0"
}

resource "azurerm_resource_group" "main_resource_group" {
  name     = "${var.resourcegroup_name}"
  location = "${var.resourcegroup_location}"

  tags {
    test_date = "${var.test_date}"
  }
}

# NETWORK

resource "azurerm_virtual_network" "CICD_network" {
  name                = "CICD-network"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.main_resource_group.location}"
  resource_group_name = "${azurerm_resource_group.main_resource_group.name}"
}

# SUBNET

resource "azurerm_subnet" "CICD_subnet" {
  name                 = "CICD-subnet"
  resource_group_name  = "${azurerm_resource_group.main_resource_group.name}"
  virtual_network_name = "${azurerm_virtual_network.CICD_network.name}"
  address_prefix       = "10.0.1.0/24"
}

# SECURITY GROUP

resource "azurerm_network_security_group" "CICD-Training_Nsg" {
  name                = "RestrictInboundForCICDserver"
  location            = "${azurerm_resource_group.main_resource_group.location}"
  resource_group_name = "${azurerm_resource_group.main_resource_group.name}"

  security_rule {
    name                       = "allow_http_Inbound"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_https_Inbound"
    priority                   = 300
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "RemoteAdmin_Inbound"
    priority                   = 400
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "${var.admin_public_ip}/32"
    destination_address_prefix = "*"
  }

  tags {
    environment = "Production"
  }
}

# NETWORK INTERFACE CARD

resource "azurerm_network_interface" "CICD-Training_NIC" {
  name                      = "CICD-NIC"
  location                  = "${azurerm_resource_group.main_resource_group.location}"
  resource_group_name       = "${azurerm_resource_group.main_resource_group.name}"
  network_security_group_id = "${azurerm_network_security_group.CICD-Training_Nsg.id}"

  ip_configuration {
    name                          = "CICD-NIC-configuration"
    subnet_id                     = "${azurerm_subnet.CICD_subnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.CICD_publicip.id}"
  }
}

# VIRTUAL MACHINE

resource "azurerm_virtual_machine" "ghqc367xzy" {
  name                  = "CICD-server"
  location              = "${azurerm_resource_group.main_resource_group.location}"
  resource_group_name   = "${azurerm_resource_group.main_resource_group.name}"
  network_interface_ids = ["${azurerm_network_interface.CICD-Training_NIC.id}"]
  vm_size               = "Standard_D4S_v3"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftSQLServer"
    offer     = "SQL2017-WS2016"
    sku       = "Enterprise"
    version   = "latest"
  }

  storage_os_disk {
    name              = "CICD-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "ghqc367xzy"
    admin_username = "${var.buildserver_user}"
    admin_password = "${var.buildserver_password}"

    #Include SetupWinRM.ps1 with variables injected as custom_data
    custom_data = "${base64encode("${file("scripts/SetupWinRM.ps1")}")}"
  }

  os_profile_windows_config {
    enable_automatic_upgrades = false
    provision_vm_agent        = true

    winrm = {
      protocol = "http"
    }

    additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "AutoLogon"
      content      = "<AutoLogon><Password><Value>${var.buildserver_password}</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>${var.buildserver_user}</Username></AutoLogon>"
    }

    #Unattend config is to enable basic auth in WinRM, required for the provisioner stage.
    additional_unattend_config {
      pass         = "oobeSystem"
      component    = "Microsoft-Windows-Shell-Setup"
      setting_name = "FirstLogonCommands"
      content      = "${file("scripts/FirstLogonCommands.xml")}"
    }
  }

  provisioner "file" {
    connection = {
      type     = "winrm"
      user     = "${var.buildserver_user}"
      password = "${var.buildserver_password}"
      host     = "${azurerm_public_ip.CICD_publicip.ip_address}"
    }

    source      = "scripts/"
    destination = "D:/scripts"
  }

  provisioner "remote-exec" {
    connection = {
      type     = "winrm"
      user     = "${var.buildserver_user}"
      password = "${var.buildserver_password}"
      host     = "${azurerm_public_ip.CICD_publicip.ip_address}"
    }

    inline = [
      "powershell.exe -sta -ExecutionPolicy Unrestricted -command \"D:\\scripts\\Install-TeamCity.ps1 -AdminPassword ${var.buildserver_password}\"",
      "powershell.exe -sta -ExecutionPolicy Unrestricted -command \"D:\\scripts\\Install-OctopusDeploy.ps1 -SqlUsername ${var.sql_user} -SqlPassword ${var.buildserver_password} -OctopusAdminUsername ${var.buildserver_user} -OctopusAdminPassword ${var.buildserver_password}\"",
      "powershell.exe -sta -ExecutionPolicy Unrestricted -command \"D:\\scripts\\Environment_Creation.ps1 -OctopusUsername ${var.buildserver_user} -OctopusPassword ${var.buildserver_password}\"",
      "powershell.exe -sta -ExecutionPolicy Unrestricted -command \"D:\\scripts\\ServiceConfiguration.ps1\"",
      "powershell.exe -sta -ExecutionPolicy Unrestricted -command \"D:\\scripts\\SysprepStartup.ps1\"",
      "powershell.exe -sta -ExecutionPolicy Unrestricted -command \"D:\\scripts\\Install-WindowsUpdates.ps1\""
    ]
  }
}

# PUBLIC IP

resource "azurerm_public_ip" "CICD_publicip" {
  name                         = "CICD-publicip"
  location                     = "${azurerm_resource_group.main_resource_group.location}"
  resource_group_name          = "${azurerm_resource_group.main_resource_group.name}"
  public_ip_address_allocation = "static"
  domain_name_label            = "dog-${lower(var.resourcegroup_name)}"
}

output "CICD_ip" {
  value = "${azurerm_public_ip.CICD_publicip.ip_address}"
}

output "CICD_fqdn" {
  value = "${azurerm_public_ip.CICD_publicip.fqdn}"
}
