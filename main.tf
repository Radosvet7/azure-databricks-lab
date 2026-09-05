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

  private_endpoint_subnet_name     = each.value.private_endpoint_subnet_name
  private_endpoint_subnet_prefixes = each.value.private_endpoint_subnet_prefixes
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
    databricks         = databricks.dev
    databricks.account = databricks.account
  }

  storage_credential_name        = "dev-storage-credential"
  external_location_name         = "dev-data-external-location"
  managed_external_location_name = "dev-uc-managed-location"
  catalog_name                   = "dev_catalog"
  workspace_id                   = module.databricks_ws["dev"].workspace_id
  access_connector_id            = module.access_connector["dev"].id
  data_container_url             = module.storage["dev"].data_container_url
  unity_catalog_container_url    = module.storage["dev"].unity_catalog_container_url
  metastore_id                   = data.databricks_metastores.this.ids["metastore_azure_northeurope"]
  schemas                        = toset(["bronze", "silver", "gold"])

  depends_on = [
    module.private_endpoint["dev"]
  ]
}

module "unity_catalog_prod" {
  source = "./modules/unity_catalog"

  providers = {
    databricks         = databricks.prod
    databricks.account = databricks.account
  }

  storage_credential_name        = "prod-storage-credential"
  external_location_name         = "prod-data-external-location"
  managed_external_location_name = "prod-uc-managed-location"
  catalog_name                   = "prod_catalog"
  workspace_id                   = module.databricks_ws["prod"].workspace_id
  access_connector_id            = module.access_connector["prod"].id
  data_container_url             = module.storage["prod"].data_container_url
  unity_catalog_container_url    = module.storage["prod"].unity_catalog_container_url
  metastore_id                   = data.databricks_metastores.this.ids["metastore_azure_northeurope"]
  schemas                        = toset(["bronze", "silver", "gold"])

  depends_on = [
    module.private_endpoint["prod"]
  ]
}

module "private_endpoint" {
  source = "./modules/private_endpoint"

  for_each = local.environments

  private_endpoint_name = "pe-adls-${each.key}"
  resource_group_name   = module.resource_group[each.key].name
  location              = module.resource_group[each.key].location

  vnet_id            = module.networking[each.key].vnet_id
  subnet_id          = module.networking[each.key].private_endpoint_subnet_id
  storage_account_id = module.storage[each.key].storage_account_id
}

module "ncc" {
  source = "./modules/ncc"

  for_each = local.environments

  providers = {
    databricks.account = databricks.account
  }

  name               = "${each.key}-ncc"
  region             = "northeurope"
  workspace_id       = module.databricks_ws[each.key].workspace_id
  storage_account_id = module.storage[each.key].storage_account_id
}

module "key_vault" {
  source = "./modules/key_vault"

  for_each = local.environments

  name                = "kv-databricks-${each.key}"
  resource_group_name = module.resource_group[each.key].name
  location            = module.resource_group[each.key].location
  tenant_id           = var.azure_tenant_id

}