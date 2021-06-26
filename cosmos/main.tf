provider "azurerm" {
  features {}
}

module "naming" {
  source = "github.com/azure/terraform-azurerm-naming"
  suffix = ["jvh"]
}

resource "azurerm_resource_group" "rg" {
  name     = module.naming.resource_group.name_unique
  location = "UK South"
}

resource "azurerm_cosmosdb_account" "ca" {
  name                = module.naming.cosmosdb_account.name_unique
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  offer_type          = "Standard"

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 10
    max_staleness_prefix    = 200
  }

  geo_location {
    location          = azurerm_resource_group.rg.location
    failover_priority = 0
  }
}

output "url"{
    value = azurerm_cosmosdb_account.ca.endpoint
}

output "cosmos_key"{
    value = azurerm_cosmosdb_account.ca.primary_key 
    sensitive = true
}
