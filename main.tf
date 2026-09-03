module "resource_group" {
  source = "./modules/resource_group"

  for_each = local.environments

  name     = each.value.resource_group_name
  location = each.value.location
}

module "networking" {
  source = "./modules/networking"

  for_each = local.environments

  resource_group_name = module.resource_group[each.key].name
  location            = module.resource_group[each.key].location

  vnet_name          = each.value.vnet_name
  vnet_address_space = each.value.vnet_address_space

  public_subnet_name     = each.value.public_subnet_name
  public_subnet_prefixes = each.value.public_subnet_prefixes

  private_subnet_name     = each.value.private_subnet_name
  private_subnet_prefixes = each.value.private_subnet_prefixes
}

module "storage" {
  source = "./modules/storage"

  for_each = local.environments

  resource_group_name = module.resource_group[each.key].name
  location            = module.resource_group[each.key].location

  storage_account_name = "${each.key}dbx${random_string.storage_suffix[each.key].result}"

  containers = toset([
    "data",
    "unity-catalog"
  ])
}

module "databricks_ws" {
  source = "./modules/databricks_ws"

  for_each = local.environments

  workspace_name      = "${each.key}-databricks-ws"
  resource_group_name = module.resource_group[each.key].name
  location            = module.resource_group[each.key].location

  vnet_id             = module.networking[each.key].vnet_id
  public_subnet_name  = module.networking[each.key].public_subnet_name
  private_subnet_name = module.networking[each.key].private_subnet_name

  public_subnet_nsg_association_id  = module.networking[each.key].public_subnet_nsg_association_id
  private_subnet_nsg_association_id = module.networking[each.key].private_subnet_nsg_association_id
}

module "access_connector" {
  source = "./modules/access_connector"

  for_each = local.environments

  name                = "${each.key}-databricks-access-connector"
  resource_group_name = module.resource_group[each.key].name
  location            = module.resource_group[each.key].location

  storage_account_id = module.storage[each.key].storage_account_id
}

module "unity_catalog_dev" {
  source = "./modules/unity_catalog"

  providers = {
    databricks = databricks.dev
  }

  storage_credential_name        = "dev-storage-credential"
  external_location_name         = "dev-data-external-location"
  managed_external_location_name = "dev-uc-managed-location"
  catalog_name                   = "dev_catalog"
  workspace_id                   = module.databricks_ws["dev"].workspace_id
  access_connector_id            = module.access_connector["dev"].id
  storage_account_name           = module.storage["dev"].storage_account_name
  data_container_name            = "data"
  unity_catalog_container_name   = "unity-catalog"
  schemas                        = toset(["bronze", "silver", "gold"])
}

module "unity_catalog_prod" {
  source = "./modules/unity_catalog"

  providers = {
    databricks = databricks.prod
  }

  storage_credential_name        = "prod-storage-credential"
  external_location_name         = "prod-data-external-location"
  managed_external_location_name = "prod-uc-managed-location"
  catalog_name                   = "prod_catalog"
  workspace_id                   = module.databricks_ws["prod"].workspace_id
  access_connector_id            = module.access_connector["prod"].id
  storage_account_name           = module.storage["prod"].storage_account_name
  data_container_name            = "data"
  unity_catalog_container_name   = "unity-catalog"
  schemas                        = toset(["bronze", "silver", "gold"])
}