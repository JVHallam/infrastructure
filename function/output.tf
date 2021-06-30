output "function_app_name"{
    value = azurerm_function_app.fn.name
}

output "function_app"{
    value = azurerm_function_app.fn
}

output "resource_group"{
    value = azurerm_resource_group.rg
}
