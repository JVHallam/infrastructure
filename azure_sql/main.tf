provider "azurerm" {
  features {}
}

module "naming" {
  source = "github.com/azure/terraform-azurerm-naming"
  suffix = ["jvh", "sql"]
}

resource "azurerm_resource_group" "sql" {
  name     = module.naming.resource_group.name_unique
  location = "UK South"
}

resource "azurerm_sql_server" "sql" {
  name                = module.naming.sql_server.name_unique
  resource_group_name = azurerm_resource_group.sql.name
  location            = azurerm_resource_group.sql.location

  version                      = "12.0"
  administrator_login          = "jvhadmin"
  administrator_login_password = "Jvhpassword1"
}

resource "azurerm_sql_database" "sql" {
  name                = "infra_database"
  resource_group_name = azurerm_resource_group.sql.name
  location            = azurerm_resource_group.sql.location

  server_name = azurerm_sql_server.sql.name
}
