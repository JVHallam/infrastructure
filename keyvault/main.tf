//Keyvault:
//az keyvault list
//az keyvault secret show --vault-name kv-jvh-knxg --name test

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

module "naming" {
  source = "github.com/azure/terraform-azurerm-naming"
  suffix = ["jvh"]
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = module.naming.resource_group.name_unique
  location = "UK South"
}

resource "azurerm_key_vault" "kv" {
  name                = module.naming.key_vault.name_unique
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    //This allows you to set and get keys, secrets and storage
    key_permissions = [
      "Get"
    ]

    secret_permissions = [
//MEans you can get it, but doesn't mean you can list them
      "Get",
//Means create, fucking
        "Set",
    //Means you can see them all in the portal
"List"
    ]

    storage_permissions = [
      "Get",
    ]
  }
}
