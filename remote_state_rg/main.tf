
provider azurerm{
    features{}
}

resource "azurerm_resource_group" "rg"{
    name = "rg-jvh-tf-state"
    location = "UK South"
}

resource "azurerm_storage_account" "st_account" {
    name = "stjvhtfstate"
    location = "UK South"
    resource_group_name = azurerm_resource_group.rg.name
    account_replication_type = "GRS"
    account_tier = "Standard"
}

resource "azurerm_storage_container" "sc_container"{
    name = "scjvhtfstate"
    storage_account_name = azurerm_storage_account.st_account.name
    container_access_type = "private"
}
