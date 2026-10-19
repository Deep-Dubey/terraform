
terraform {                         // Terraform configuration block
  required_providers {              // Specifies which providers this project requires
    azurerm = {                     // Azure Resource Manager provider
      source  = "hashicorp/azurerm" // Official provider source in the Terraform Registry
      version = "~> 3.0"            // Allows compatible versions in the 3.x series
    }
  }
}


provider "azurerm" { // Configures the Azure provider so Terraform can manage Azure resources
  features {}        // Required Azure provider configuration
}


resource "azurerm_resource_group" "mtc-rg" { // Creates a resource group in Microsoft Azure
  name     = "mtc-resources"                 // Name of the resource group in Azure
  location = "Central India"                 // Azure region where the resource group will be created

  tags = {                         // Adds metadata tags to the resource group
    environment = "Terraform Demo" // Identifies the environment as a Terraform demo
  }
}


resource "azurerm_virtual_network" "mtc-vnet" {                // Creates a virtual network in Azure
  name                = "mtc-vnet"                             // Name of the virtual network
  location            = azurerm_resource_group.mtc-rg.location // Uses the same location as the resource group
  resource_group_name = azurerm_resource_group.mtc-rg.name     // Resource group where the virtual network will be created
  address_space       = ["10.0.0.0/16"]                        // IP address range available to the virtual network

  tags = {                         // Adds metadata tags to the virtual network
    environment = "Terraform Demo" // Identifies the environment as a Terraform demo
  }
}


resource "azurerm_subnet" "mtc-subner" {                       // Creates a subnet inside the virtual network
  name                 = "mtc-subnet"                          // Name of the subnet
  virtual_network_name = azurerm_virtual_network.mtc-vnet.name // Virtual network to which the subnet belongs
  resource_group_name  = azurerm_resource_group.mtc-rg.name    // Resource group where the subnet will be created
  address_prefixes     = ["10.0.1.0/24"]                       // Subnet IP range within the virtual network address space
}


resource "azurerm_network_security_group" "mtc-nsg" {          // Creates a Network Security Group in Azure
  name                = "mtc-nsg"                              // Name of the Network Security Group
  location            = azurerm_resource_group.mtc-rg.location // Uses the same location as the resource group
  resource_group_name = azurerm_resource_group.mtc-rg.name     // Resource group where the NSG will be created

  tags = {                         // Adds metadata tags to the NSG
    environment = "Terraform Demo" // Identifies the environment as a Terraform demo
  }
}


resource "azurerm_network_security_rule" "allow-ssh" { // Creates a security rule to allow SSH traffic
  name                       = "Allow-SSH"             // Name of the security rule
  priority                   = 100                     // Rule priority; lower numbers are evaluated first
  direction                  = "Inbound"               // Applies to incoming network traffic
  access                     = "Allow"                 // Allows traffic matching this rule
  protocol                   = "*"                     // Allows TCP/ICP traffic
  source_port_range          = "*"                     // Allows traffic from any source port
  destination_port_range     = "22"                    // SSH destination port
  source_address_prefix      = "*"                     // Replace with your actual public IP address
  destination_address_prefix = "*"                     // Applies to any destination IP address

  resource_group_name         = azurerm_resource_group.mtc-rg.name          // Resource group containing the NSG
  network_security_group_name = azurerm_network_security_group.mtc-nsg.name // NSG to which this rule belongs
}


resource "azurerm_subnet_network_security_group_association" "mtc-nsg-association" { // Associates the NSG with the subnet
  subnet_id                 = azurerm_subnet.mtc-subner.id                           // ID of the subnet to protect
  network_security_group_id = azurerm_network_security_group.mtc-nsg.id              // ID of the NSG to associate
}




resource "azurerm_public_ip" "mtc-public-ip" {                 // Creates a public IP address in Azure
  name                = "mtc-public-ip"                        // Name of the public IP resource
  location            = azurerm_resource_group.mtc-rg.location // Uses the resource group's location
  resource_group_name = azurerm_resource_group.mtc-rg.name     // Resource group where the public IP is created

  allocation_method = "Static"   // Assigns a stable public IP address
  sku               = "Standard" // Uses the Standard public IP SKU

  tags = {
    environment = "Terraform Demo" // Identifies the environment
  }
}

