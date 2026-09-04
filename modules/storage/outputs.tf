output "storage_account_id" {
  value = azurerm_storage_account.this.id
}

output "storage_account_name" {
  value = azurerm_storage_account.this.name
}

output "primary_dfs_host" {
  value = azurerm_storage_account.this.primary_dfs_host
}

output "container_names" {
  value = {
    for key, container in azurerm_storage_container.this :
    key => container.name
  }
}

output "data_container_url" {
  value = "abfss://${azurerm_storage_container.this["data"].name}@${azurerm_storage_account.this.name}.dfs.core.windows.net/"
}

output "unity_catalog_container_url" {
  value = "abfss://${azurerm_storage_container.this["unity-catalog"].name}@${azurerm_storage_account.this.name}.dfs.core.windows.net/"
}