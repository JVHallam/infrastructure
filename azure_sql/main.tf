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

resource "azurerm_mssql_server" "sql" {
  name                = module.naming.sql_server.name_unique
  resource_group_name = azurerm_resource_group.sql.name
  location            = azurerm_resource_group.sql.location

  version                      = "12.0"
  administrator_login          = "jvhadmin"
  administrator_login_password = "Jvhpassword1"
}

resource "azurerm_mssql_database" "sql" {
  name      = "infra_database"
  server_id = azurerm_mssql_server.sql.id
}

resource "azurerm_mssql_firewall_rule" "example" {
  name             = "AllowHomeAddress"
  server_id        = azurerm_mssql_server.sql.id
  start_ip_address = var.client_ip_address
  end_ip_address   = var.client_ip_address
}

locals {
  test = { "key" = "value" }
  connection = {
    "Server"                 = azurerm_mssql_server.sql.fully_qualified_domain_name
    "Initial Catalog"        = azurerm_mssql_database.sql.name
    "User ID"                = azurerm_mssql_server.sql.administrator_login
    "Password"               = azurerm_mssql_server.sql.administrator_login_password
    "TrustServerCertificate" = "False"
    "Connection Timeout"     = "30"
  }
  connection_array  = [for key in keys(local.connection) : "${key}=${local.connection[key]}"]
  connection_string = join(";", local.connection_array)
}
