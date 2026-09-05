resource "azurerm_private_endpoint" "this" {
  name                = var.private_endpoint_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.private_endpoint_name}-connection"
    private_connection_resource_id = var.storage_account_id
    is_manual_connection           = false
    subresource_names              = ["dfs"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.this.id]
  }
}

resource "azurerm_private_dns_zone" "this" {
  name                = "privatelink.dfs.core.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                = "${var.private_endpoint_name}-vnet-link"
  private_dns_zone_id = azurerm_private_dns_zone.this.id
  virtual_network_id  = var.vnet_id
}