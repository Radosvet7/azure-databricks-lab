output "vnet_id" {
  value = azurerm_virtual_network.databricks.id
}

output "public_subnet_id" {
  value = azurerm_subnet.databricks_public.id
}

output "private_subnet_id" {
  value = azurerm_subnet.databricks_private.id
}

output "public_subnet_name" {
  value = azurerm_subnet.databricks_public.name
}

output "private_subnet_name" {
  value = azurerm_subnet.databricks_private.name
}

output "public_subnet_nsg_association_id" {
  value = azurerm_subnet_network_security_group_association.databricks_public.id
}

output "private_subnet_nsg_association_id" {
  value = azurerm_subnet_network_security_group_association.databricks_private.id
}