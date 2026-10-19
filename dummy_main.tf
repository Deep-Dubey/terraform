terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

// Creates the Azure resource group
resource "azurerm_resource_group" "mtc-rg" {
  name     = "XXXX"
  location = "XXXX"

  tags = {
    environment = "Terraform Demo"
  }
}

// Creates the virtual network
resource "azurerm_virtual_network" "mtc-vnet" {
  name                = "XXXX"
  location            = azurerm_resource_group.mtc-rg.location
  resource_group_name = azurerm_resource_group.mtc-rg.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "Terraform Demo"
  }
}

// Creates the subnet
resource "azurerm_subnet" "mtc-subner" {
  name                 = "XXXX"
  virtual_network_name = azurerm_virtual_network.mtc-vnet.name
  resource_group_name  = azurerm_resource_group.mtc-rg.name
  address_prefixes     = ["10.0.1.0/24"]
}

// Creates the Network Security Group
resource "azurerm_network_security_group" "mtc-nsg" {
  name                = "XXXX"
  location            = azurerm_resource_group.mtc-rg.location
  resource_group_name = azurerm_resource_group.mtc-rg.name

  tags = {
    environment = "Terraform Demo"
  }
}

// Allows SSH from your current public IP only
resource "azurerm_network_security_rule" "allow-ssh" {
  name                       = "Allow-SSH"
  priority                   = 100
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "*"
  source_port_range          = "*"
  destination_port_range     = "22"
  source_address_prefix      = var.admin_source_cidr
  destination_address_prefix = "*"

  resource_group_name         = azurerm_resource_group.mtc-rg.name
  network_security_group_name = azurerm_network_security_group.mtc-nsg.name
}

// Associates the NSG with the subnet
resource "azurerm_subnet_network_security_group_association" "mtc-nsg-association" {
  subnet_id                 = azurerm_subnet.mtc-subner.id
  network_security_group_id = azurerm_network_security_group.mtc-nsg.id
}

// Creates a static public IP
resource "azurerm_public_ip" "mtc-public-ip" {
  name                = "XXXX"
  location            = azurerm_resource_group.mtc-rg.location
  resource_group_name = azurerm_resource_group.mtc-rg.name

  allocation_method = "Static"
  sku               = "Standard"

  tags = {
    environment = "Terraform Demo"
  }
}

// Creates the network interface
resource "azurerm_network_interface" "mtc-nic" {
  name                = "XXXX"
  location            = azurerm_resource_group.mtc-rg.location
  resource_group_name = azurerm_resource_group.mtc-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.mtc-subner.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mtc-public-ip.id
  }

  tags = {
    environment = "Terraform Demo"
  }
}

// Creates the Ubuntu Linux VM
resource "azurerm_linux_virtual_machine" "mtc-vm" {
  name                = "XXXX"
  computer_name       = "XXXX"
  resource_group_name = azurerm_resource_group.mtc-rg.name
  location            = azurerm_resource_group.mtc-rg.location

  size = "Standard_B2s_v2"
  zone = "2"

  admin_username = "XXXX"

  network_interface_ids = [
    azurerm_network_interface.mtc-nic.id
  ]

  // Sends the startup script to the VM
  custom_data = filebase64("${path.module}/customdata.tpl")

  // Configures SSH key authentication
  admin_ssh_key {
    username   = "XXXX"
    public_key = file(pathexpand("~/.ssh/azurerm-ssh-key.pub"))
  }

  // Configures the operating system disk
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  // Selects Ubuntu 22.04 LTS
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = {
    environment = "Terraform Demo"
  }

  // Configures SSH on the Windows machine running Terraform
  provisioner "local-exec" {
    interpreter = var.host_os == "windows" ? ["PowerShell", "-Command"] : ["bash", "-c"]

    command = templatefile("${var.host_os}/windows-ssh-script.tpl", {
      hostname     = "XXXX"
      host_address = self.public_ip_address
      user         = "XXXX"
      identityfile = pathexpand("~/.ssh/azurerm-ssh-key")
    })
  }
}

data "azurerm_public_ip" "existing-ip" {
  name                = azurerm_public_ip.mtc-public-ip.name
  resource_group_name = azurerm_resource_group.mtc-rg.name
}

output "public_ip_address" {
  value = "${azurerm_linux_virtual_machine.mtc-vm.name}: ${data.azurerm_public_ip.existing-ip.ip_address}"
}
