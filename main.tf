terraform{
    backend "azurerm"{
        resource_group_name = "rg-jvh-tf-state"
        storage_account_name = "stjvhtfstate"
        container_name = "scjvhtfstate"
        key = "infra.tfstate"
    }
}

provider azurerm {
    features{}
}

module "aks"{
    source = "./kubernetes"
}

output "cluster_name"{
    value = module.aks.cluster_name
}

output "cluster_rg_name"{
    value = module.aks.resource_group_name
}
