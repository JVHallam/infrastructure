terraform {
  backend "azurerm" {
    resource_group_name  = "rg-jvh-tf-state"
    storage_account_name = "stjvhtfstate"
    container_name       = "scjvhtfstate"
    key                  = "infra.tfstate"
  }
}

provider "azurerm" {
  features {}
}


module "naming" {
  source = "github.com/azure/terraform-azurerm-naming"
  suffix = ["jvh", "fn"]
}

resource "azurerm_resource_group" "rg" {
  name     = module.naming.resource_group.name_unique
  location = "UK South"
}

resource "azurerm_storage_account" "sa" {
  name                     = module.naming.storage_account.name_unique
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "sp" {
  name                = module.naming.app_service_plan.name_unique
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_application_insights" "api" {
  name                = module.naming.application_insights.name_unique
  location            = "UK South"
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}

resource "azurerm_function_app" "fn" {
  name                       = module.naming.function_app.name_unique
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  app_service_plan_id        = azurerm_app_service_plan.sp.id
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  version                    = "~3"

  app_settings = merge({
    APPINSIGHTS_INSTRUMENTATIONKEY         = azurerm_application_insights.api.instrumentation_key
    APPLICATION_INSIGHTS_CONNECTION_STRING = azurerm_application_insights.api.connection_string
  }, var.app_settings)
}
