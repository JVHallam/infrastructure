provider "azurerm" {
    features {}
}

module "naming"{
    source = "github.com/azure/terraform-azurerm-naming"
    prefix = [ "jvh" ]
}

locals{
    loc = "UK South"
}

resource "azurerm_resource_group" "queue" {
  name     = module.naming.resource_group.name_unique
  location = local.loc
}

//wtf is this?
resource "azurerm_servicebus_namespace" "queue" {
  name                = module.naming.servicebus_namespace.name_unique
  location            = local.loc
  resource_group_name = azurerm_resource_group.queue.name
  sku                 = "Standard"
}

resource "azurerm_servicebus_queue" "queue" {
  name                = module.naming.servicebus_queue.name_unique
  resource_group_name = azurerm_resource_group.queue.name
  namespace_name      = azurerm_servicebus_namespace.queue.name
  enable_partitioning = true
}

output "queue_name"{
    value = azurerm_servicebus_queue.queue.name
}

output "namespace_connection_string"{
    value = azurerm_servicebus_namespace.queue.name
}
