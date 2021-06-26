provider "azurerm" {
  features {}
}

module "naming"{
    source = "github.com/azure/terraform-azurerm-naming"
    prefix = [ "jvh" ]
}

resource "azurerm_resource_group" "rg" {
  name     = module.naming.resource_group.name_unique
  location = "UK South"
}

resource "azurerm_virtual_network" "vn" {
  name                = module.naming.virtual_network.name_unique
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "sn" {
  name                 = module.naming.subnet.name_unique
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vn.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "pi" {
  name                = module.naming.public_ip.name_unique
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "ni" {
  name                = module.naming.network_interface.name_unique
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sn.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id         =  azurerm_public_ip.pi.id
  }
}

resource "azurerm_linux_virtual_machine" "example" {
  name                = module.naming.linux_virtual_machine.name_unique
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.ni.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}

output "public_ip"{
    value = azurerm_linux_virtual_machine.example.public_ip_address
}
