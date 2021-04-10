module "naming"{
    source = "github.com/azure/terraform-azurerm-naming"
    suffix = [ "perma", terraform.workspace ]
}

resource "azurerm_resource_group" "rg"{
    name = module.naming.resource_group.name_unique
    location = "UK South"
}

resource "azurerm_kubernetes_cluster" "cluster" {
  name                = module.naming.kubernetes_cluster.name_unique
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "permaaks1"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

output "resource_group_name"{
    value = azurerm_resource_group.rg.name
}

output "cluster_name"{
    value = azurerm_kubernetes_cluster.cluster.name
}
