data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  tenant_id                     = var.tenant_id
  sku_name                      = "standard"
  rbac_authorization_enabled    = true
  public_network_access_enabled = true
  purge_protection_enabled = true
}

resource "azurerm_key_vault_key" "storage_cmk" {
  name         = "storage-cmk"
  key_vault_id = azurerm_key_vault.this.id

  key_type = "RSA"
  key_size = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "unwrapKey",
    "wrapKey"
  ]

  depends_on = [
    azurerm_role_assignment.terraform_key_admin
  ]
}

resource "azurerm_role_assignment" "terraform_key_admin" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Crypto Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "storage_cmk" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = var.storage_principal_id
}