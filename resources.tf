resource "random_string" "storage_suffix" {
  for_each = local.environments

  length  = 8
  special = false
  upper   = false
}

resource "azurerm_storage_account_customer_managed_key" "this" {
  for_each = local.environments

  storage_account_id = module.storage[each.key].storage_account_id
  key_vault_key_id   = module.key_vault[each.key].storage_cmk_id
}